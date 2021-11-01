
import UIKit
import StoreKit

protocol SettingsListModelDelegate: class {
    func sendEmailDelegate(strEmailBody : String)
    func previewPDFDelegate(strPDFBody : String)
    func switchChanged(item: String)
    func restoreInApp()
}

class SettingsListModel: NSObject {

     var arrItems = ["Export History","Rate App","Share App","More App"]

    weak var delegate: SettingsListModelDelegate?

    var htmlFileObj = HTMLFileIOModel()
    
    var strEmailBodyData : String = ""

    func reloadSettingItems(tableView : UITableView ,isPDFPreview : Bool, strStartDate: String, strEndDate : String) -> (String)
    {
        tableView.reloadData()
        tableView.tableFooterView = UIView()
        htmlFileObj.reloadTasks(isPDFPreview: isPDFPreview, strStartDate: strStartDate, strEndDate: strEndDate)
        
        if(htmlFileObj.arrTasks.count > 0)
        {
            if(isPDFPreview)
            {
                let htmlTableUIStr = htmlFileObj.PDFaddTableRowDesignFor(numOfRows: String(htmlFileObj.arrTasks.count))
                htmlFileObj.PDFwriteFileContentToDocDir(writeString: htmlTableUIStr)
                           
                           
                let htmlFileStr = htmlFileObj.PDFrenderHTMLTaskListTable()
                htmlFileObj.PDFwriteFileContentToDocDir(writeString: htmlFileStr)
                   
                strEmailBodyData = htmlFileObj.PDFreadFileContentFromDocDir()
                   
                return strEmailBodyData
            }
            else
            {
                let htmlTableUIStr = htmlFileObj.addTableRowDesign(numOfRows: String(htmlFileObj.arrTasks.count))
                htmlFileObj.writeFileContentToDocDir(writeString: htmlTableUIStr)
                           
                           
                let htmlFileStr = htmlFileObj.renderHTMLTaskListTable()
                htmlFileObj.writeFileContentToDocDir(writeString: htmlFileStr)
                   
                strEmailBodyData = htmlFileObj.readFileContentFromDocDir()
                   
                return strEmailBodyData
            }
           
        }
        return ""
       
    }
    
}
class SettingTableCell: UITableViewCell{
    
    @IBOutlet var lblText: UILabel!
    @IBOutlet var imgArrow: UIImageView!
}

extension SettingsListModel: UITableViewDataSource, UITableViewDelegate
{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return arrItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell : SettingTableCell! = tableView.dequeueReusableCell(withIdentifier: "SettingTableCell") as? SettingTableCell
            cell.lblText.text = arrItems[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            switch indexPath.row {
            case 0:
                delegate?.previewPDFDelegate(strPDFBody: strEmailBodyData)
                break
            case 1:
                let url = URL(string: rateappID)
                UIApplication.shared.open(url!, options: [:] , completionHandler: nil)
               /* if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    // Fallback on earlier versions
                }*/
                break
            case 2:
                let url = URL(string: ShareAppID)
                UIApplication.shared.open(url!, options: [:] , completionHandler: nil)
                break
            case 3:
                let url = URL(string: MoreAppID)
                UIApplication.shared.open(url!, options: [:] , completionHandler: nil)
                break
            default:
                break
            }
        }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
        {
             return UITableView.automaticDimension
        }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    @objc func switchChanged(_ sender: UISwitch) {
        delegate?.switchChanged(item: arrItems[sender.tag])
    }

    @objc func restoreInApp(_: UIButton) {
        delegate?.restoreInApp()
    }
}
