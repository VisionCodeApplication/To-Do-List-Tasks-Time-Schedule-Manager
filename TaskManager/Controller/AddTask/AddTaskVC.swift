
import UIKit
import Lottie
import GIFImageView

class AddTaskVC: UIViewController,UITextFieldDelegate {
    @IBOutlet var viewHeader : CustomHeaderView!

    var currentTaskType : TaskTypeEnum = .Task

    var ID : Int = 0

    var isedit : Bool = false

    var Detail : TaskModel = TaskModel()

    @IBOutlet var snimstionview: UIView!
    
    @IBOutlet var Animationimageview: UIImageView!
    
    @IBOutlet var txtDiscriptionview: UIView!
    @IBOutlet var txtprojecttitleview: UIView!
    @IBOutlet var txtdateview: UIView!
    @IBOutlet var txttitleview: UIView!
    @IBOutlet weak var viewTime : UIView!

    @IBOutlet weak var lblStartTime : UILabel!

    @IBOutlet weak var lblEndTime : UILabel!
  
    @IBOutlet weak var txtFTitle : UITextField!

    @IBOutlet weak var txtFProjName : UITextField!
  
    @IBOutlet weak var txtVDecription : UITextView!
 
    @IBOutlet weak var txtFDate : UITextField!

    @IBOutlet weak var txtFStartTime : UITextField!
    @IBOutlet var txtStartTimeView: UIView!
    
    @IBOutlet weak var txtFEndTime : UITextField!
    @IBOutlet var txtendtimeview: UIView!
    
    @IBOutlet weak var constViewTimeHeight : NSLayoutConstraint!
  
    @IBOutlet weak var constViewProjNameHeight : NSLayoutConstraint!
    
    @IBOutlet var Constviewstarttimetxtviewhight: NSLayoutConstraint!
    @IBOutlet weak var btnSave : UIButton!

    @IBOutlet weak var btnDelete : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("currentTaskType \(currentTaskType)")
        btnDelete.isHidden = true
        
        txtFStartTime.addInputViewDatePicker(target: self, selector: #selector(startTimeDoneClicked), mode: .time, isFromPDFView: false)
        txtFEndTime.addInputViewDatePicker(target: self, selector: #selector(endTimeDoneClicked), mode: .time, isFromPDFView: false)
        
        txtFDate.addInputViewDatePicker(target: self, selector: #selector(dateDoneClicked), mode: .date, isFromPDFView: false)
        
        self.txtFStartTime.delegate = self
        self.txtFEndTime.delegate = self
        self.txtFDate.delegate = self
        if(isedit)
        {
            loadTask()
        }
        viewTime.layer.masksToBounds = false
        viewTime.shadowColor = .darkGray
        viewTime.shadowOffset = .zero
        viewTime.shadowOpacity = 1
        
        txtdateview.layer.masksToBounds = false
        txtdateview.shadowColor = .darkGray
        txtdateview.shadowOffset = .zero
        txtdateview.shadowOpacity = 1
        
        txttitleview.layer.masksToBounds = false
        txttitleview.shadowColor = .darkGray
        txttitleview.shadowOffset = .zero
        txttitleview.shadowOpacity = 1
        
        txtprojecttitleview.layer.masksToBounds = false
        txtprojecttitleview.shadowColor = .darkGray
        txtprojecttitleview.shadowOffset = .zero
        txtprojecttitleview.shadowOpacity = 1
        
        txtDiscriptionview.layer.masksToBounds = false
        txtDiscriptionview.shadowColor = .darkGray
        txtDiscriptionview.shadowOffset = .zero
        txtDiscriptionview.shadowOpacity = 1
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           changeui()
    }
    
    func changeui()
    {
        switch currentTaskType {
        case .Task:
            task()
            break
            
        case .Meeting:
            meeting()
            break

        case .Reminder:
            reminder()
            break
            
        default:
            task()
            break
        }
    }
    func reminder()
    {
        Animationimageview.image = UIImage.animatedImage(named: "Reminderclock")
        txtFEndTime.isHidden = true
        txtendtimeview.isHidden = true
        if(isedit)
        {
            self.viewHeader.lblTitle.text = "Update Reminder"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Reminder"
        }
        Constviewstarttimetxtviewhight.constant = 46
        constViewProjNameHeight.constant = 0
        constViewTimeHeight.constant = 47
        
        
    }
    func meeting()
    {
//        notaskview = .init(name: "Meetinganimation")
//        notaskview!.loopMode = .loop
//        notaskview!.animationSpeed = 0.5
//        notaskview.frame = CGRect(x: 0, y: 0, width: 360, height: 160)
//        snimstionview.addSubview(notaskview!)
//        notaskview.play()
//
        Animationimageview.image = UIImage.animatedImage(named: "Meeting")
        if(isedit)
        {
            self.viewHeader.lblTitle.text = "Update Meeting"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Meeting"
        }
        constViewProjNameHeight.constant = 0
    }
    func task()
    {
        Animationimageview.image = UIImage.animatedImage(named: "Task")
        
        if(isedit)
        {
            self.viewHeader.lblTitle.text = "Update Task"
        }
        else{
            self.viewHeader.lblTitle.text = "Add Task"
        }
        
        constViewTimeHeight.constant = 104
    }
    func loadTask()
    {
        btnDelete.isHidden = false
        let datePickerDateTime : UIDatePicker = txtFDate.inputView as! UIDatePicker
        datePickerDateTime.setDate(from: Detail.Task_Date as String, format: DDBSmallDateFormat)
        
        let datePickerStartTime : UIDatePicker = txtFStartTime.inputView as! UIDatePicker
        datePickerStartTime.setDate(from: Detail.Start_Time as String, format: DFullTimeFormat)
        
        let datePickerEndTime : UIDatePicker = txtFEndTime.inputView as! UIDatePicker
        datePickerEndTime.setDate(from: Detail.End_Time as String, format: DFullTimeFormat)
        
        txtFTitle.text = Detail.Title as String
        txtFProjName.text = Detail.Project_Name as String
        txtVDecription.text = Detail.Description as String
        txtFDate.text = Detail.Task_Date as String
        txtFStartTime.text = Detail.Start_Time as String
        txtFEndTime.text = Detail.End_Time as String
        
        btnSave.setTitle("Update", for: .normal)

    }
    
    func setnotification()
    {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let arrReminders = DBManager.sharedInstance.selectReminderListFromTable()
        for item in arrReminders {
            let content = UNMutableNotificationContent()
            content.title = item.Title as String
            content.body = item.Description as String
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "remind.aiff"))

            let strDate = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: item.Task_Date as String)

            var time: String = String().getTimeFromString(timeFormat: DFullTimeFormat, timeStr: item.Start_Time as String)
            
            if(item.Task_Type as String == TaskTypeEnum.Meeting.rawValue)
            {
                var tempDate = String().convertDateFormatter(dateStr: item.Start_Time as String, timeFormat: DFullTimeFormat)
                tempDate.addTimeInterval(TimeInterval(-15.0 * 60.0))
                let timeTemp = tempDate.toString(dateFormat: DFullTimeFormat)
                
                time = String().getTimeFromString(timeFormat: DFullTimeFormat, timeStr: timeTemp)
            }
            
            let morningOfChristmasComponents = NSDateComponents()
            morningOfChristmasComponents.day = Int(strDate.components(separatedBy: "-")[2])!
            morningOfChristmasComponents.month = Int(strDate.components(separatedBy: "-")[1])!
            morningOfChristmasComponents.year = Int(strDate.components(separatedBy: "-")[0])!
            morningOfChristmasComponents.hour = Int(time.components(separatedBy: ":")[0])!
            morningOfChristmasComponents.minute = Int(time.components(separatedBy: ":")[1])!
            morningOfChristmasComponents.second = 0

            let morningOfChristmas = NSCalendar.current.date(from: morningOfChristmasComponents as DateComponents)

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: morningOfChristmas!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "\(item.ID)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    func delete()
    {
        DBManager.sharedInstance.deleteThisTask(Id: "\(ID)")
        if(currentTaskType == TaskTypeEnum.Reminder)
        {
            removeReminder()
        }
    }
    func removeReminder()
    {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(ID)"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(ID)"])
        
    }
    
    func validateTextFields() -> Bool {
        var valid:Bool = true
        
        if txtFTitle.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtFTitle.attributedPlaceholder = NSAttributedString(string: "Please enter Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFTitle.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if (txtFProjName.text!.isEmpty && currentTaskType == .Task)
        {
            //Change the placeholder color to red for textfield email if
            txtFProjName.attributedPlaceholder = NSAttributedString(string: "Please enter Project name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFProjName.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFDate.text!.isEmpty {
            //Change the placeholder color to red for textfield email if
            txtFDate.attributedPlaceholder = NSAttributedString(string: "Please enter Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFDate.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFStartTime.text!.isEmpty && currentTaskType != .Task {
            //Change the placeholder color to red for textfield email if
            txtFStartTime.attributedPlaceholder = NSAttributedString(string: "Please enter Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFStartTime.AnimationShakeTextField(textField: txtFTitle)
        }
        
        if txtFEndTime.text!.isEmpty && currentTaskType == .Meeting {
            //Change the placeholder color to red for textfield email if
            txtFEndTime.attributedPlaceholder = NSAttributedString(string: "Please enter Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            valid = false
        }else{
            txtFEndTime.AnimationShakeTextField(textField: txtFTitle)
        }
        
        return valid
    }
    // MARK: - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @objc func startTimeDoneClicked() {
        if let  datePicker = txtFStartTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let time = Date().getStringTimeFromDate(date: datePicker.date)
            if(currentTaskType.rawValue == TaskTypeEnum.Reminder.rawValue)
            {
                txtFStartTime.text = Date().getStringTimeFromDate(date: datePicker.date)
            }
            else{
                let isValid = DBManager.sharedInstance.checkValidStartEndTime(strStartTime: time, strEndTime: "", strDate: txtFDate.text!, isStartTime: true,taskId: ID)
                if isValid {
                    txtFStartTime.text = Date().getStringTimeFromDate(date: datePicker.date)
                }
                else {
                    CommonFunctions.showMessage(Title: "", message: "Please select valid time.")
                }
            }
            
        }
        txtFStartTime.resignFirstResponder()
    }
    
    @objc func endTimeDoneClicked() {
        if let  datePicker = txtFEndTime.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium

            let startTime = txtFStartTime.text?.convertDateFormatter(dateStr: txtFStartTime.text!, timeFormat: DFullTimeFormat)
            let endTime = Date().getStringTimeFromDate(date: datePicker.date)

            let isGreater = self.checkEndTimeGreater(startTime: txtFStartTime.text!, endTime: endTime)

            if isGreater {
                let isValid = DBManager.sharedInstance.checkValidStartEndTime(strStartTime: txtFStartTime.text!, strEndTime: endTime, strDate: txtFDate.text!, isStartTime: false,taskId: ID)
                if isValid {
                    txtFEndTime.text = Date().getStringTimeFromDate(date: datePicker.date)
                }
                else {
                    CommonFunctions.showMessage(Title: "", message: "Please select valid time.")
                }
            }
        }
        txtFEndTime.resignFirstResponder()
    }

    func checkEndTimeGreater(startTime: String, endTime: String) -> Bool {
        var isGreater = true
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateIn = formatter.date(from: startTime)
        let dateOut = formatter.date(from: endTime)

        let result: ComparisonResult = (dateIn?.compare(dateOut!))!
        if result == .orderedDescending || result == .orderedSame {
            print("date2 is later than date1")
            CommonFunctions.showMessage(Title: "", message: "End time must be greater than Start time!")
            isGreater = false
        }
        return isGreater
    }
    
    @objc func dateDoneClicked() {
        if let  datePicker = txtFDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            txtFDate.text = datePicker.date.toString(dateFormat: DDBSmallDateFormat)
        }
        txtFDate.resignFirstResponder()
    }
    @IBAction func btnSaveClicked()
    {
        let isNotEmpty : Bool = validateTextFields()
        if(isNotEmpty)
        {
            let taskModel : TaskModel = TaskModel()
            taskModel.Title = txtFTitle.text as NSString? ?? "" as NSString
            taskModel.Description = txtVDecription.text as NSString? ?? "" as NSString
            taskModel.Task_Type = NSString(string: currentTaskType.rawValue)
            taskModel.Task_Date = String().getDateFromString(dateFormat: DDBSmallDateFormat, dateStr: (txtFDate.text as NSString? ?? "" as NSString) as String) as NSString
           
            taskModel.Project_Name = txtFProjName.text as NSString? ?? "" as NSString
            taskModel.Date_Created = Date().toString(dateFormat: DTaskdateFormat) as NSString
            taskModel.Start_Time = txtFStartTime.text as NSString? ?? "" as NSString
            taskModel.End_Time = txtFEndTime.text as NSString? ?? "" as NSString
            taskModel.UserId = "1"
            taskModel.TotalTaskHours = "-"
            if(isedit)
            {
                taskModel.Task_Status = Detail.Task_Status as NSString? ?? "" as NSString
                taskModel.TotalTaskHours = taskModel.TotalTaskHours as NSString? ?? "" as NSString
                
                DBManager.sharedInstance.UpdateTaskOfID(taskDetail: taskModel, taskID: ID)
            }
            else
            {
                taskModel.Task_Status = NSString(string: TaskStatusEnum.const_Pending.rawValue)
                DBManager.sharedInstance.AddTask(taskDetail: taskModel)
            }
            setnotification()
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func btnDeleteClicked()
    {
        let alert = UIAlertController(title: "Delete \(currentTaskType.rawValue)", message: "Are you sure you want to delete this?", preferredStyle: .alert)

        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.delete()
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
