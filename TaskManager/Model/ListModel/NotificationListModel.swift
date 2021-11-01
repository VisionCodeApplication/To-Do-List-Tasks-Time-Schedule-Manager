import UIKit

class NotificationListModel: NSObject {

    var arrItems: [TaskModel] = []
    let cellReuseIdentifier = "NotificationCell"
    let cellSpacingHeight: CGFloat = 0.0
    
    func reloadNotiList(arrList : [TaskModel], tableView : UITableView) {
        arrItems = arrList
        tableView.reloadData()
    }
}

extension NotificationListModel: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : NotificationTableCell! = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? NotificationTableCell

        if cell == nil {
            tableView.register(UINib(nibName: "NotificationTableCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? NotificationTableCell
        }
        let objCell = arrItems[indexPath.row]
        
        let strTimeConverted = String().convertTimeFormat(inputFormat: DFullTimeFormat, outFormat: DTaskTimeFormat, time: objCell.Start_Time as String)
        
        cell.lblTitle.text = objCell.Title as String
        cell.lblDesc.text = objCell.Description as String
        cell.lblTaskType.text = "  " + "\(TaskTypeEnum.Reminder.rawValue)" + "  "
        cell.lblTime.text = "\(objCell.Task_Date as String)  "  + strTimeConverted
        cell.vwLine.backgroundColor = UIColor.TaskType[indexPath.row%3]
        return cell
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

}
