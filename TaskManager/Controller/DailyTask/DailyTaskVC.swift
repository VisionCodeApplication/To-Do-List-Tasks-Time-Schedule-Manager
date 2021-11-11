
import UIKit
import GoogleMobileAds
import Lottie
import Firebase
import UnityAds

class DailyTaskVC: UIViewController,UITextFieldDelegate,GADBannerViewDelegate, UnityAdsDelegate {
    func unityAdsReady(_ placementId: String) {
        print("Unity ads is ready")
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
        print(error)
        print(message)
    }
    
    func unityAdsDidStart(_ placementId: String) {
        print(placementId)
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        print("Unity ads is finish")
        if (state != .skipped) {
            print("Wathch full ad")
        }
    }
    

    @IBOutlet var lblDailyStatus: UILabel!

    @IBOutlet var Notaskanimationview: UIView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var TotalTaskView: UIView!
    
    @IBOutlet weak var progressBarViewDone: UIView!
    @IBOutlet weak var progressBarViewTodo: UIView!
    @IBOutlet weak var progressBarViewInProgress: UIView!

    @IBOutlet weak var constraintTableViewHeight : NSLayoutConstraint!
   
    @IBOutlet weak var viewInsideScroll : UIView!
    
   @IBOutlet weak var scrollViewMain  : UIScrollView!
    
    var taskDetailForCompletedHR = TaskModel()

    var objcDailyTaskListModel = DailyTaskListModel()
    
    var arrTasks = [TaskModel]()
    var donearr = [TaskModel]()
    
    var floatPending : Float = 0.0
    var floatInProgress: Float = 0.0
    var floatDone: Float = 0.0
    var DBvalue = Int()
    var DBvalueforads = Int()
    
    @IBOutlet weak var lblTotalTask: UILabel!
    
    @IBOutlet weak var lblDoneTasks: UILabel!
    @IBOutlet weak var lblPendingTasks: UILabel!
    @IBOutlet weak var lblInProgressTasks: UILabel!

    private var interstitial: GADInterstitial!

    var bannerView: GADBannerView!
    @IBOutlet var vwGoogleAd: UIView!

    var adsTimer = Timer()
    var tapp = Int()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UnityAds.setDebugMode(true)
        UnityAds.initialize("4278828",delegate: self)
        
        scrollViewMain.isScrollEnabled = true
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProgress), name: NSNotification.Name(rawValue: "ProgressViewReload"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(completedHoursClick(_:)), name: NSNotification.Name(rawValue: "completedHoursClick"), object: nil)
        TotalTaskView.isUserInteractionEnabled = true
        var tapges = UITapGestureRecognizer(target: self, action: #selector(ontap))
        TotalTaskView.addGestureRecognizer(tapges)
        
        LaunchInterstitialAd()
    }
    @objc func ontap(){
        if tapp == 0 {
            tapp = 1
            donearr = objcDailyTaskListModel.donearrr
            self.tableView.delegate = self.objcDailyTaskListModel
            self.tableView.dataSource = self.objcDailyTaskListModel
            tableView.reloadData()
            tableView.isHidden = false
            scrollViewMain.isScrollEnabled = true
        }else{
            tapp = 0
           tableView.isHidden = true
           scrollViewMain.isScrollEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let database = Database.database().reference()
        
        database.child("hidedata").observe(.value) { snapshot in
            print(snapshot.value!)
            self.DBvalue = snapshot.value as! Int
            if AppDelegate.sharedInstance.isPurchased {
                self.vwGoogleAd.isHidden = true
            } else {
                if self.DBvalue == 1 {
                    self.vwGoogleAd.isHidden = false
                }else{
                    self.vwGoogleAd.isHidden = true
                }
            }
        }
        database.child("ads").observe(.value) { snapshot in
            print(snapshot.value!)
            self.DBvalueforads = snapshot.value as! Int
            if(self.DBvalue == 1){
                self.gad()
            }
        }
        tapp = 0
        tableView.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        reload()
        initialization()
    }
    private func LaunchInterstitialAd() {
         interstitial = GADInterstitial(adUnitID: fullAdID)
         let request = GADRequest()
         interstitial.load(request)
     }

     private func showInterstitialAd() {
         interstitial.present(fromRootViewController: self)
             LaunchInterstitialAd()
     }
    
    func initialization() {
       lblDailyStatus.text = Date().toString(dateFormat: DTaskdateFormatFull)
    }
    
    func gad() {
        if DBvalueforads == 1 {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            bannerView.adUnitID = bannerAdID
            bannerView.rootViewController = self
            bannerView.delegate = self
            vwGoogleAd.addSubview(bannerView)
            bannerView.load(GADRequest())
        }
        else if DBvalueforads == 2{
            print("unity ads")
            UnityAds.show(self, placementId: "Banner_iOS")
        }
    }
    
    func reload() {
        
        self.tableView.delegate = self.objcDailyTaskListModel
        self.tableView.dataSource = self.objcDailyTaskListModel
        
        let allTaskWithProgress  = DBManager.sharedInstance.selectTodaysTaskList(sortBy: 0)
        arrTasks = allTaskWithProgress.0
        floatPending = Float(allTaskWithProgress.1)
        floatDone = Float(allTaskWithProgress.2)
        floatInProgress = Float(allTaskWithProgress.3)
        let largest : Float = Float(arrTasks.count)

        perform(#selector(Loading), with: NSNumber.init(value: largest), afterDelay: 1.0)
        self.objcDailyTaskListModel.reloadList(arrList: arrTasks, tableView: self.tableView, footerHeight: 10.0)
        countcheck()
    }

    func countcheck() {
        if arrTasks.count == 0 {
          //  NoTaskView!.isHidden = true
            Notaskanimationview.isHidden = false
        }
        else {
          //  NoTaskView!.isHidden = true
            Notaskanimationview.isHidden = true
        }
    }

    @objc func reloadProgress() {
        reload()
    }
    
    @objc func completedHoursClick(_ notification: NSNotification) {
        
        if let taskDetail = notification.userInfo?["Task"] as? TaskModel {
            self.taskDetailForCompletedHR = taskDetail
        }
       }

    @objc func Loading(num : NSNumber) {

        let totalValue = floatInProgress+floatPending+floatDone
        lblTotalTask.text = "\(Int(totalValue))"

        if(Int(totalValue) > 0)
        {
            lblDoneTasks.text =  "\(Int(floatDone))"
            lblInProgressTasks.text =  "\(Int(floatInProgress))"
            lblPendingTasks.text =  "\(Int(floatPending))"
        }
        
        else{
            lblDoneTasks.text =  "\(Int(0))"
            lblInProgressTasks.text =  "\(Int(0))"
            lblPendingTasks.text =  "\(Int(0))"
        }
    }
    @IBAction func btnFloatingClicked()
    {
        let alert = UIAlertController(title: "Choose Style", message: "Please Choose any one.", preferredStyle: .alert)
        let Mettingbtn = UIAlertAction(title: "Meeting", style: .default) { UIAlertAction in
        self.AddTask(type: .Meeting)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Reminderbtn = UIAlertAction(title: "Reminder", style: .default) {  UIAlertAction in
            self.AddTask(type: .Reminder)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    print("show unity ads")
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Taskbtn = UIAlertAction(title: "Task", style: .default) { UIAlertAction in
            self.AddTask(type: .Task)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Canclebtn = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(Mettingbtn)
        alert.addAction(Reminderbtn)
        alert.addAction(Taskbtn)
        alert.addAction(Canclebtn)
       present(alert, animated: true, completion: nil)
        
    }

    func AddTask(type : TaskTypeEnum)
    {
        let vc = UIStoryboard(name: "AddTaskVC", bundle: nil).instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC

        vc?.currentTaskType = type

        AppDelegate.sharedInstance.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let obj = object as? UITableView {
            if obj == self.tableView && keyPath == "contentSize" {
                constraintTableViewHeight.constant = tableView.contentSize.height
                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
}
