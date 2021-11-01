import UIKit

let bannerAdID = "ca-app-pub-3940256099942544/6300978111"
let fullAdID = "ca-app-pub-3940256099942544/1033173712"
let rateappID = " "
let ShareAppID = " "
let MoreAppID = " "
 
let DTaskdateFormatFull = "dd MMMM yyyy"
let DTaskdateFormat = "dd-MMM-yyyy"
let DTaskTimeFormat = "hh:mm a"

let DSmallDateFormat = "dd-MM-yyyy"
let DDBSmallDateFormat = "yyyy-MM-dd"
let DFullTimeFormat = "HH:mm"

let DtodayDate = Date()

let DBundlePathToTaskTableHTMLTemplate = Bundle.main.path(forResource: "taskTable", ofType: "html")
let DBundlePathToTaskTablePDFHTMLTemplate = Bundle.main.path(forResource: "PDFHistoryTable", ofType: "html")
let DHTMLFileName = "taskTable.html"
let DPDFHTMLFileName = "PDFHistoryTable.html"


enum TaskStatusEnum : String {
    case const_InProgress = "In Progress"
    case const_Completed = "Completed"
    case const_Pending = "Pending"
    
    static func index(of aStatus: TaskStatusEnum) -> Int {
        let elements = [TaskStatusEnum.const_InProgress, TaskStatusEnum.const_Completed, TaskStatusEnum.const_Pending]

        return elements.index(of: aStatus)!
    }
}
enum TaskTypeEnum : String {
    case Task = "Task"
    case Meeting = "Meeting"
    case Reminder = "Reminder"
}

struct DB {
    static let Name = "TaskManager.sqlite"
}
