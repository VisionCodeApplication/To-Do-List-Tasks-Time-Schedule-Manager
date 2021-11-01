
import UIKit
import MessageUI
import SVProgressHUD
import GoogleMobileAds
import Firebase

public struct stuctProducts {
    public static let SwiftShopping = "com.xxx.task.removeads"
    private static let productIdentifiers: Set<ProductIdentifier> = [stuctProducts.SwiftShopping]
    public static let store = IAPHelper(productIds: stuctProducts.productIdentifiers)
}

class SettingsVC: UIViewController,MFMailComposeViewControllerDelegate,SettingsListModelDelegate,UIDocumentInteractionControllerDelegate,GADBannerViewDelegate {

    @IBOutlet var viewHeader : CustomHeaderView!

    @IBOutlet weak var txtStartDate: UITextField!
    
    @IBOutlet weak var txtEndDate: UITextField!
    
    @IBOutlet weak var btnExportSend: UIButton!
    
    @IBOutlet weak var viewDateSelection: UIView!
    
    var isPDFPreview: Bool = false
    
    var strHTMLTablePreview: String = ""
    var DBvalue = Int()
    var settingModelObj = SettingsListModel()
    
    @IBOutlet var tableView: UITableView!

    var productBuy: SKProduct? {
        didSet {
            guard let product = productBuy else { return }
            if stuctProducts.store.isProductPurchased(product.productIdentifier) {
                AppDelegate.sharedInstance.saveUserDefault(value: true, Key: AppDelegate.sharedInstance.keyPurchased)
            } else if IAPHelper.canMakePayments() {
                AppDelegate.sharedInstance.saveUserDefault(value: false, Key: AppDelegate.sharedInstance.keyPurchased)
            } else {}
        }
    }

    var bannerView: GADBannerView!
    @IBOutlet var vwGoogleAd: UIView!
     private var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSelectionShowHide(hide: true, isEmailSend: false)
        viewHeader?.lblTitle?.text = "Settings"
        viewHeader.setTitle()
        
        txtStartDate.addInputViewDatePicker(target: self, selector: #selector(startDateDoneClicked), mode: .date , isFromPDFView: true)
        txtEndDate.addInputViewDatePicker(target: self, selector: #selector(endDateDoneClicked), mode: .date , isFromPDFView: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDateSelection.isHidden = true
        reloadApps()
        
        let database = Database.database().reference()
        
        database.child("hidedata").observe(.value) { snapshot in
            print(snapshot.value!)
            self.DBvalue = snapshot.value as! Int
            if AppDelegate.sharedInstance.isPurchased {
                self.vwGoogleAd.isHidden = true
            } else {
                if self.DBvalue == 1 {
                    self.vwGoogleAd.isHidden = false
                    self.gad()
                }else{
                    self.vwGoogleAd.isHidden = true
                }
            }
        }
    }
    func gad() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = bannerAdID
        bannerView.rootViewController = self
        bannerView.delegate = self
        vwGoogleAd.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    func reloadApps() {
        
        self.tableView.delegate = self.settingModelObj
        self.tableView.dataSource = self.settingModelObj
        
        strHTMLTablePreview = self.settingModelObj.reloadSettingItems(tableView: tableView, isPDFPreview: false, strStartDate: "", strEndDate: "")
        self.settingModelObj.delegate = self
        
        txtStartDate.text = Date().toString(dateFormat: DDBSmallDateFormat)
        txtEndDate.text = Date().toString(dateFormat: DDBSmallDateFormat)
        
    }
    func restoreInApp() {
        stuctProducts.store.restorePurchases()
    }

    func switchChanged(item: String) {
        if AppDelegate.sharedInstance.fetchUserDefault(Key: AppDelegate.sharedInstance.keyPurchased) == false {
            stuctProducts.store.buyProduct(productBuy!)
        } else {}
    }

    func sendEmailDelegate(strEmailBody: String) {
        
        strHTMLTablePreview = strEmailBody
        viewSelectionShowHide(hide: false, isEmailSend: true)
    }
    
    func previewPDFDelegate(strPDFBody: String) {
        
        strHTMLTablePreview = strPDFBody
        viewSelectionShowHide(hide: false, isEmailSend: false)
    }
    
    func validateDate() -> Bool
    {
        var valid : Bool = true

        if txtStartDate.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtStartDate.attributedPlaceholder = NSAttributedString(string: "Please select Start Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtStartDate.AnimationShakeTextField(textField: txtStartDate)
        }
        
        if txtEndDate.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtEndDate.attributedPlaceholder = NSAttributedString(string: "Please select End Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtEndDate.AnimationShakeTextField(textField: txtEndDate)
        }
        
        if !txtEndDate.text!.isEmpty {
            let date1 = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: txtStartDate.text!)

            let date2 = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: txtEndDate.text!)

            let currentDate = Date().toString(dateFormat: DDBSmallDateFormat)
            
            if(date1 > currentDate || date2 > currentDate)
            {
                CommonFunctions.showMessage(Title: "Alert!", message: "Future date not allowed!")
                valid = false
            }
            else if(date1>date2)
            {
                CommonFunctions.showMessage(Title: "Alert!", message: "Start Date should not be more than end date")
                valid = false
            }
        }
        return valid
    }
    func viewSelectionShowHide(hide : Bool, isEmailSend : Bool)
    {
        viewDateSelection.isHidden = hide
        if(isEmailSend)
        {
            txtEndDate.isHidden = true
            txtStartDate.placeholder = "Select Date"
            isPDFPreview = false
        }
        else{
            txtEndDate.isHidden = false
            txtStartDate.placeholder = "Start Date"
            isPDFPreview = true
        }
    }
    
    @IBAction func btnPreviewClicked()
    {
        if(isPDFPreview)
        {
            if(validateDate())
            {
                SVProgressHUD.show()
                strHTMLTablePreview = self.settingModelObj.reloadSettingItems(tableView: tableView, isPDFPreview: true, strStartDate: txtStartDate.text!, strEndDate: txtEndDate.text!)
                
                strHTMLTablePreview.exportHTMLContentToPDF(HTMLContent: strHTMLTablePreview)
                
                let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let pdfFilename = documents.appending("/file.pdf")
                
                
                let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: pdfFilename))
                dc.delegate = self as UIDocumentInteractionControllerDelegate
                dc.presentPreview(animated: true)
                
            }
        }
        else
        {
            strHTMLTablePreview = self.settingModelObj.reloadSettingItems(tableView: tableView, isPDFPreview: false, strStartDate: txtStartDate.text!, strEndDate: txtEndDate.text!)
            
            launchEmail(strBody: strHTMLTablePreview)
            
        }
    }
    
    @IBAction func btnCloseDateSelectionViewClicked()
    {
        viewSelectionShowHide(hide: true, isEmailSend: false)
    }
    
    func launchEmail(strBody: String) {

        if MFMailComposeViewController.canSendMail() {
            SVProgressHUD.show()
            let emailTitle = "Work Report - \(txtStartDate.text!.strDatetoFormat(dateFormat: DTaskdateFormatFull))"
            let messageBody = "Hello,</br>Good Evening Sir,</br>Here is my work report for the day \(txtStartDate.text!.strDatetoFormat(dateFormat: DTaskdateFormat)).</br></br>" + strBody

            let toRecipents = [""]

            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: true)
            mc.setToRecipients(toRecipents)

            self.present(mc, animated: true, completion: nil)
            SVProgressHUD.dismiss()
        }
        else
        {
            CommonFunctions.showMessage(Title: "Error!", message: "Mail composer error")
        }
    }
    
    
    @objc func startDateDoneClicked() {
        if let  datePicker = txtStartDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            txtStartDate.text = datePicker.date.toString(dateFormat: DDBSmallDateFormat)
        }
        txtStartDate.resignFirstResponder()
    }
    
    @objc func endDateDoneClicked() {
        if let  datePicker = txtEndDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            txtEndDate.text = datePicker.date.toString(dateFormat: DDBSmallDateFormat)
        }
        txtEndDate.resignFirstResponder()
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        SVProgressHUD.dismiss()
        return self
    }
}

