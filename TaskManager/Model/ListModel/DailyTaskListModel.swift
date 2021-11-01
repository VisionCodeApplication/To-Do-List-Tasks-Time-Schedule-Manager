
import UIKit
import GoogleMobileAds

class DailyTaskListModel: NSObject {

    
    var arrItems: [TaskModel] = []
    var donearrr = [TaskModel]()
    var statuscount = 0
    var footerheight: CGFloat = 0.0
    var tblView: UITableView!
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    func reloadList(arrList : [TaskModel], tableView : UITableView, footerHeight: CGFloat) {
        arrItems = arrList
        footerheight = footerHeight
        tblView = tableView
        tableView.reloadData()
    }
    
}

extension DailyTaskListModel: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return arrItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : TaskTableCell! = tableView.dequeueReusableCell(withIdentifier: "DailyCell") as? TaskTableCell

        if cell == nil {
            tableView.register(UINib(nibName: "TaskTableCell", bundle: nil), forCellReuseIdentifier: "DailyCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell") as? TaskTableCell
        }
        cell.lblTitle.text = arrItems[indexPath.row].Title as String

        let anEnumType = TaskTypeEnum(rawValue: (arrItems[indexPath.row].Task_Type as String))!
        cell.btnTaskType?.setTitle("  "+"\(anEnumType.rawValue)"+"  ", for: .normal)
        
        if anEnumType.rawValue == "Meeting" {
            cell.imgViewLeftDash.image = UIImage(named: "Meeting")
        }else if anEnumType.rawValue == "Reminder"{
            cell.imgViewLeftDash.image = UIImage(named: "Reminder")
        }
        else if anEnumType.rawValue == "Task"{
            cell.imgViewLeftDash.image = UIImage(named: "Task")
        }
        
            let enumtask = TaskStatusEnum(rawValue: (arrItems[indexPath.row].Task_Status as String))!
        if (arrItems[indexPath.row].Task_Status == "Completed") {
            cell.progressbar.tintColor = UIColor(red: 0.325, green: 0.775, blue: 0.382, alpha: 1)
            cell.progressbar.progress = 100 / 100
            donearrr.append(arrItems[indexPath.row])
        }
        else if (arrItems[indexPath.row].Task_Status == "In Progress") {
            cell.progressbar.tintColor = UIColor(red: 0.352, green: 0.800, blue: 0.892, alpha: 1)
            cell.progressbar.progress = 50 / 100
        }
        else if (arrItems[indexPath.row].Task_Status == "Pending") {
            cell.progressbar.tintColor = UIColor(red: 0.379, green: 0.276, blue: 0.775, alpha: 1)
            cell.progressbar.progress = 10/100
        }

        let time = arrItems[indexPath.row].Start_Time as String
        cell.lblTime.text = time.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time)

        let index = TaskStatusEnum.index(of: TaskStatusEnum(rawValue: String(self.arrItems[indexPath.row].Task_Status))!)

        cell.vwTaskBG.backgroundColor = .white

        cell.lblEndTime.isHidden = true

        if(anEnumType == .Meeting || anEnumType == .Task)
        {
            let time1 = arrItems[indexPath.row].Start_Time as String
            let time2 = arrItems[indexPath.row].End_Time as String

            cell.lblTime.text = (time1.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time1))
            cell.lblEndTime.text = (time2.convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: time2))
            cell.lblEndTime.isHidden = false
        }

        let todaysDate = Date().toString(dateFormat: DDBSmallDateFormat)
        if arrItems[indexPath.row].Task_Date as String == todaysDate {
            cell.btnTaskStatusEdit.tag = indexPath.row
            cell.btnTaskStatusEdit.isUserInteractionEnabled = true
        }
        else {
            cell.btnTaskStatusEdit.isUserInteractionEnabled = false
        }

        cell.btnTaskStatusEdit.addTarget(self, action: #selector(showAlert(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let todaysDate = Date().toString(dateFormat: DDBSmallDateFormat)
        if arrItems[indexPath.row].Task_Date as String == todaysDate {
            let vc = UIStoryboard(name: "AddTaskVC", bundle: nil).instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC

            vc?.isedit = true
            vc?.ID = arrItems[indexPath.row].ID

            vc?.currentTaskType = TaskTypeEnum(rawValue: String(arrItems[indexPath.row].Task_Type))!
            vc?.Detail = DBManager.sharedInstance.selectTaskOfSelectedId(Id: arrItems[indexPath.row].ID)

            AppDelegate.sharedInstance.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerheight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: footerheight))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    @IBAction func showAlert(_ sender: AnyObject) {
        let alert = UIAlertController(title: "", message: "Select Status", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_InProgress.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.statuscount = 0
            self.tblView.reloadData()
            self.updateTaskStatus(status: TaskStatusEnum.const_InProgress.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_Completed.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.statuscount = 2
            self.tblView.reloadData()
            self.updateTaskStatus(status: TaskStatusEnum.const_Completed.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: TaskStatusEnum.const_Pending.rawValue, style: .default , handler:{ (UIAlertAction)in
            self.statuscount = 1
            self.updateTaskStatus(status: TaskStatusEnum.const_Pending.rawValue as NSString, index: sender.tag)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
        }))

        AppDelegate.sharedInstance.navigationController?.topViewController!.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    func updateTaskStatus(status: NSString, index: Int) {
        let objModel = self.arrItems[index]
        objModel.Task_Status = status
        if(self.arrItems[index].Task_Type as String == TaskTypeEnum.Task.rawValue)
        {
            if(status as String == TaskStatusEnum.const_Completed.rawValue)
            {
                objModel.TotalTaskHours = CommonFunctions.getDifferenceTotalTimeInMinutes(from: String().convertDateFormatter(dateStr: (objModel.Start_Time as String), timeFormat: DFullTimeFormat), EndTime: String().convertDateFormatter(dateStr: (objModel.End_Time as String), timeFormat: DFullTimeFormat)) as NSString
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
                self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
                NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
            }
            else if(status as String == TaskStatusEnum.const_InProgress.rawValue)
            {
                objModel.TotalTaskHours = CommonFunctions.getDifferenceTotalTimeInMinutes(from: String().convertDateFormatter(dateStr: (objModel.Start_Time as String), timeFormat: DFullTimeFormat), EndTime: String().convertDateFormatter(dateStr: (objModel.End_Time as String), timeFormat: DFullTimeFormat)) as NSString
                
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
                self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
                NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
            }
            else
            {
                objModel.TotalTaskHours = "-"
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
                self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
                NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
            }
            
        }
        else
        {
            DBManager.sharedInstance.UpdateTaskOfID(taskDetail: objModel, taskID: objModel.ID)
            self.reloadList(arrList: [objModel], tableView: tblView, footerHeight: self.footerheight)
            NotificationCenter.default.post(name: Notification.Name("ProgressViewReload"), object: nil)
        }
    }
    
    

}
