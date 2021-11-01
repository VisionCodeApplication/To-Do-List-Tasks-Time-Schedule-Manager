import UIKit

class NotificationsVC: UIViewController {

    @IBOutlet var viewHeader : CustomHeaderView!
   
    var objcNotiListModel = NotificationListModel()
    
    @IBOutlet var tableView: UITableView!

    var arrNotifications = [TaskModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeader?.lblTitle?.text = "Notifications"
        viewHeader?.setTitle()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        reloadTable()
    }
    func reloadTable()
    {
        self.tableView.delegate = self.objcNotiListModel
        self.tableView.dataSource = self.objcNotiListModel
                   
                  
        let allTaskWithProgress  = DBManager.sharedInstance.selectMeetingReminderFromTable()
        arrNotifications = allTaskWithProgress
        
        self.objcNotiListModel.reloadNotiList(arrList: arrNotifications, tableView: self.tableView)
    }
}
