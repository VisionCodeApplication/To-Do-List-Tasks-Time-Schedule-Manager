import UIKit
import SQLite3

class DBManager: NSObject {
    
    static let sharedInstance = DBManager()

    var db: OpaquePointer?
    
    func createDB() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(DB.Name)
        
        print(fileURL.path)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }

    func createTable() {
        
        let strQuery : String = "CREATE TABLE IF NOT EXISTS Tasks (Id INTEGER PRIMARY KEY AUTOINCREMENT, Title VARCHAR, Description VARCHAR, Task_Type VARCHAR, Date_Created VARCHAR, Start_Time VARCHAR, End_Time VARCHAR, Task_Date VARCHAR, Task_Status VARCHAR, Project_Name VARCHAR, UserId INTEGER, TotalTaskHours VARCHAR);" +
            "CREATE TABLE IF NOT EXISTS UserDetail (UserId INTEGER PRIMARY KEY AUTOINCREMENT,  First_Name VARCHAR, Last_Name VARCHAR, Password);"
        
        if sqlite3_exec(db, strQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    func selectTaskListOfSelectedDate(sortBy : Int, strDate : String) -> ([TaskModel],Int,Int,Int) {
        
        var arrAllTask : [TaskModel] = []
        print(arrAllTask)
        var intCountPending = 0
        var intCountCompleted = 0
        var intCountInProgress = 0
        
        var strSortBy = ""
       
        if sortBy == 0 {
            strSortBy = " order by Start_Time DESC"
        }
       
        
        let queryString = "SELECT * FROM Tasks where Task_Date = '\(strDate)'"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            item.ID = Int(sqlite3_column_int(stmt, 0))
            item.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            item.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            item.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            item.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            item.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            item.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            item.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            item.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            item.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            item.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            item.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString

            let anEnumStatus = TaskStatusEnum(rawValue: (item.Task_Status as String))!
           if anEnumStatus == .const_Completed
           {
               intCountCompleted = intCountCompleted + 1
           }
           if anEnumStatus == .const_Pending
           {
               intCountPending = intCountPending + 1
           }
           if anEnumStatus == .const_InProgress
           {
               intCountInProgress = intCountInProgress + 1
           }
             arrAllTask.append(item)
        }
        return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
    }

    func selectTaskExceptReminderOfSelectedDate(sortBy : Int, strDate : String) -> ([TaskModel],Int,Int,Int) {
        
        var arrAllTask : [TaskModel] = []
        
        var intCountPending = 0
        var intCountCompleted = 0
        var intCountInProgress = 0
        
        var strSortBy = ""
       
        if sortBy == 0 {
            strSortBy = " order by Start_Time DESC"
        }
       
        
        let queryString = "SELECT * FROM Tasks where Task_Date = '\(strDate)' AND (Task_Type !='\(TaskTypeEnum.Reminder.rawValue)')"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            item.ID = Int(sqlite3_column_int(stmt, 0))
            item.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            item.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            item.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            item.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            item.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            item.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            item.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            item.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            item.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            item.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            item.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString

            let anEnumStatus = TaskStatusEnum(rawValue: (item.Task_Status as String))!
           if anEnumStatus == .const_Completed
           {
               intCountCompleted = intCountCompleted + 1
           }
           if anEnumStatus == .const_Pending
           {
               intCountPending = intCountPending + 1
           }
           if anEnumStatus == .const_InProgress
           {
               intCountInProgress = intCountInProgress + 1
           }
             arrAllTask.append(item)
        }
        return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
    }
    func selectTaskOfSelectedId(Id : Int) -> TaskModel {
        
        let objTask : TaskModel = TaskModel()
        
    
        let queryString = "SELECT * FROM Tasks where Id = \(Id)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return objTask
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
           
            objTask.ID = Int(sqlite3_column_int(stmt, 0))
            objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString

        }
        return objTask
    }

    func selectAllTasksFromTable() -> [TaskModel] {
        
        var arrAllTask : [TaskModel] = []
        
    
        let queryString = "SELECT * FROM Tasks"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrAllTask
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let objTask : TaskModel = TaskModel()
            objTask.ID = Int(sqlite3_column_int(stmt, 0))
            objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
            
            arrAllTask.append(objTask)
        }
        return arrAllTask
    }

    func selectTodaysTaskList(sortBy : Int) -> ([TaskModel],Int,Int,Int) {
        
        var intCountPending = 0
        var intCountCompleted = 0
        var intCountInProgress = 0
        
        var arrAllTask : [TaskModel] = []
        
        var strSortBy = ""
       
        if sortBy == 0 {
            strSortBy = " order by Start_Time DESC"
        }
       
        let strDate = Date().dateStringWith(strFormat: DDBSmallDateFormat)
         
        let queryString = "SELECT * FROM Tasks where Task_Date = '\(strDate)'"+"\(strSortBy)"
     
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            
            item.ID = Int(sqlite3_column_int(stmt, 0))
            item.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            item.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            item.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            item.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            item.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            item.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            item.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            item.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            item.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            item.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            item.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
            
             let anEnumStatus = TaskStatusEnum(rawValue: (item.Task_Status as String))!
            if anEnumStatus == .const_Completed
            {
                intCountCompleted = intCountCompleted + 1
            }
            if anEnumStatus == .const_Pending
            {
                intCountPending = intCountPending + 1
            }
            if anEnumStatus == .const_InProgress
            {
                intCountInProgress = intCountInProgress + 1
            }
                
            arrAllTask.append(item)
        }
        return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
    }
    func selectMeetingReminderFromTable() -> [TaskModel] {
        
        var arrAllTask : [TaskModel] = []
        
         let strDate = Date().dateStringWith(strFormat: DDBSmallDateFormat)
         let strTime = Date().dateStringWith(strFormat: DFullTimeFormat)
        
        let queryString = "SELECT * FROM Tasks where (Task_Type ='\(TaskTypeEnum.Meeting.rawValue)' OR Task_Type ='\(TaskTypeEnum.Reminder.rawValue)') AND ((Task_Date <= '\(strDate)' AND Start_Time <= '\(strTime)') OR Task_Date < '\(strDate)') order by Task_Date DESC limit 0,10"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrAllTask
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let objTask : TaskModel = TaskModel()
            objTask.ID = Int(sqlite3_column_int(stmt, 0))
            objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
            
            arrAllTask.append(objTask)
        }
        return arrAllTask
    }
    func selectReminderListFromTable() -> [TaskModel] {
        
        var arrAllTask : [TaskModel] = []
        
        let queryString = "SELECT * FROM Tasks where (Task_Type ='\(TaskTypeEnum.Reminder.rawValue)' OR Task_Type ='\(TaskTypeEnum.Meeting.rawValue)')"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrAllTask
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let objTask : TaskModel = TaskModel()
            objTask.ID = Int(sqlite3_column_int(stmt, 0))
            objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
            
            arrAllTask.append(objTask)
        }
        return arrAllTask
    }
    func selectTaskFromToTable(strStartDate : String , strEndDate : String , sortBy : Int) -> ([TaskModel],Int,Int,Int) {
        
        var arrAllTask : [TaskModel] = []
        var intCountPending = 0
        var intCountCompleted = 0
        var intCountInProgress = 0
        
        var strSortBy = ""
              
        if sortBy == 0 {
           strSortBy = " order by Task_Date DESC"
        }
        else if sortBy == 1 {
            strSortBy = " order by Task_Date ASC"
        }
        
        let queryString = "SELECT * FROM Tasks where (Task_Date BETWEEN '\(strStartDate)' AND '\(strEndDate)')" + "\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
        }
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let objTask : TaskModel = TaskModel()
            objTask.ID = Int(sqlite3_column_int(stmt, 0))
            objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
            objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
            objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
            objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
            objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
            objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
            objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
            objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
            objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
            objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
            objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
            
            let anEnumStatus = TaskStatusEnum(rawValue: (objTask.Task_Status as String))!
            if anEnumStatus == .const_Completed
            {
                intCountCompleted = intCountCompleted + 1
            }
            if anEnumStatus == .const_Pending
            {
                intCountPending = intCountPending + 1
            }
            if anEnumStatus == .const_InProgress
            {
                intCountInProgress = intCountInProgress + 1
            }
            
            arrAllTask.append(objTask)
        }
        return (arrAllTask,intCountPending,intCountCompleted,intCountInProgress)
    }
    
    typealias CompletionHandler = (_ success:Bool) -> Void

    func carryForwardPendingInProgressTaskToCurrentDate(tasksFromDate : String, tasksToDate : String, newToDate : String, completionHandler: CompletionHandler) {
        var arrAllTask : [TaskModel] = []
        
        if(tasksFromDate != newToDate)
        {
            let queryString = "SELECT * FROM Tasks where ((Task_Type = '\(TaskTypeEnum.Task.rawValue)') AND (Task_Date >= '\(tasksFromDate)' AND Task_Date < '\(tasksToDate)')) AND ((Task_Status = '\(TaskStatusEnum.const_Pending.rawValue)') OR (Task_Status = '\(TaskStatusEnum.const_InProgress.rawValue)')) group by Id"
            
            var stmt:OpaquePointer?
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
            }
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let objTask : TaskModel = TaskModel()
                objTask.ID = Int(sqlite3_column_int(stmt, 0))
                objTask.Title = String(cString:sqlite3_column_text(stmt, 1)) as NSString
                objTask.Description = String(cString:sqlite3_column_text(stmt, 2)) as NSString
                objTask.Task_Type = String(cString:sqlite3_column_text(stmt, 3)) as NSString
                objTask.Date_Created = String(cString: sqlite3_column_text(stmt, 4)) as NSString
                objTask.Start_Time = String(cString:sqlite3_column_text(stmt, 5)) as NSString
                objTask.End_Time = String(cString:sqlite3_column_text(stmt, 6)) as NSString
                objTask.Task_Date = String(cString:sqlite3_column_text(stmt, 7)) as NSString
                objTask.Task_Status = String(cString:sqlite3_column_text(stmt, 8)) as NSString
                objTask.Project_Name = String(cString:sqlite3_column_text(stmt, 9)) as NSString
                objTask.UserId = String(cString:sqlite3_column_text(stmt, 10)) as NSString
                objTask.TotalTaskHours = String(cString:sqlite3_column_text(stmt, 11)) as NSString
                
                arrAllTask.append(objTask)
                AddTaskCopy(taskDetail: objTask, newTaskDate: newToDate)
            }
            completionHandler(true)
        }
        
    }
    func AddTaskCopy(taskDetail : TaskModel, newTaskDate: String) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO Tasks (Title, Description, Task_Type, Date_Created, Start_Time, End_Time, Task_Date, Task_Status , Project_Name , UserId, TotalTaskHours) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, taskDetail.Title.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, taskDetail.Description.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, taskDetail.Task_Type.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, taskDetail.Date_Created.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, taskDetail.Start_Time.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, taskDetail.End_Time.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, newTaskDate, -1, nil)
            sqlite3_bind_text(insertStatement, 8, taskDetail.Task_Status.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 9, taskDetail.Project_Name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, taskDetail.UserId.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, taskDetail.TotalTaskHours.utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func checkValidStartEndTime(strStartTime: String, strEndTime: String, strDate: String, isStartTime: Bool, taskId: Int) -> Bool {

            var isValid = true

            var queryString = ""
            if isStartTime {
                queryString = "SELECT id from Tasks where Task_Date = '\(strDate)' and ('\(strStartTime)' >= Start_Time and '\(strStartTime)' < End_Time) and Id <> '\(taskId)'"
            }
            else {
                queryString = "SELECT id from Tasks where Task_Date = '\(strDate)' and ((Start_Time BETWEEN '\(strStartTime)' and '\(strEndTime)') AND (Start_Time BETWEEN '\(strStartTime)' and '\(strEndTime)' ) ) and Id <> '\(taskId)'"
            }

            var stmt:OpaquePointer?

            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return isValid
            }
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let title = String(cString:sqlite3_column_text(stmt, 0)) as NSString
                if title.length > 0 {
                    isValid = false
                }
            }
            return isValid
        }
       func getTaskList(Id : Int) -> String {
           
           var folderName : String = ""
           
           let queryString = "SELECT Name FROM Folders where Id = \(Id)"
           
           var stmt:OpaquePointer?
           
           if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
               let errmsg = String(cString: sqlite3_errmsg(db)!)
               print("error preparing insert: \(errmsg)")
               return folderName
           }
           
           while(sqlite3_step(stmt) == SQLITE_ROW){
               folderName = String(cString: sqlite3_column_text(stmt, 0))
           }
           return folderName
       }
    func selectDocumentListByFolder(sortBy : Int, folderId :Int) -> [TaskModel] {
        
        var arrDocuments : [TaskModel] = []
        
        var strSortBy = ""
        if sortBy == 0 {
            strSortBy = " order by name ASC"
        }
        else if sortBy == 1 {
            strSortBy = " order by name DESC"
        }
        else if sortBy == 2 {
            strSortBy = " order by Date DESC"
        }
        else if sortBy == 3 {
            strSortBy = " order by Date ASC"
        }
        else if sortBy == 4 {
            strSortBy = " order by totalPages DESC"
        }
        
        let queryString = "SELECT doc.*, count(page.Id) as totalPages FROM Documents doc left outer join Pages page on page.DocumentId = doc.Id where doc.FolderId = \(folderId) group by doc.Id"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrDocuments
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            arrDocuments.append(item)
        }
        return arrDocuments
    }
    func selectDocumentListByDocIds(sortBy : Int, docIds :String) -> [TaskModel] {
        
        var arrDocuments : [TaskModel] = []
        
        var strSortBy = ""
        if sortBy == 0 {
            strSortBy = " order by name ASC"
        }
        else if sortBy == 1 {
            strSortBy = " order by name DESC"
        }
        else if sortBy == 2 {
            strSortBy = " order by Date DESC"
        }
        else if sortBy == 3 {
            strSortBy = " order by Date ASC"
        }
        else if sortBy == 4 {
            strSortBy = " order by totalPages DESC"
        }
        
        let queryString = "SELECT doc.*, count(page.Id) as totalPages FROM Documents doc left outer join Pages page on page.DocumentId = doc.Id where doc.Id IN (\(docIds)) group by doc.Id"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrDocuments
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            arrDocuments.append(item)
        }
        return arrDocuments
    }
    func searchDocList(sortBy : Int, search : String) -> [TaskModel] {
        
        var arrDocuments : [TaskModel] = []
        
        var strSearch = " name LIKE "+"'\(search)%'"
        strSearch = strSearch + " OR name LIKE '%\(search)'"
        strSearch = strSearch + " OR name LIKE '%\(search)%'"
        
        var strSortBy = ""
        if sortBy == 0 {
            strSortBy = " order by name ASC"
        }
        else if sortBy == 1 {
            strSortBy = " order by name DESC"
        }
        else if sortBy == 2 {
            strSortBy = " order by Date DESC"
        }
        else if sortBy == 3 {
            strSortBy = " order by Date ASC"
        }
        else if sortBy == 4 {
            strSortBy = " order by totalPages DESC"
        }
        
        let queryString = "SELECT doc.*, count(page.Id) as totalPages FROM Documents doc left outer join Pages page on page.DocumentId = doc.Id where \(strSearch) group by doc.Id"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrDocuments
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            arrDocuments.append(item)
        }
        return arrDocuments
    }
    func searchDocListByFolder(sortBy : Int, search : String, folderId : Int) -> [TaskModel] {
        
        var arrDocuments : [TaskModel] = []
        
        var strSearch = "name LIKE "+"'\(search)%'"
        strSearch = strSearch + " OR name LIKE '%\(search)'"
        strSearch = strSearch + " OR name LIKE '%\(search)%'"
        
        var strSortBy = ""
        if sortBy == 0 {
            strSortBy = " order by name ASC"
        }
        else if sortBy == 1 {
            strSortBy = " order by name DESC"
        }
        else if sortBy == 2 {
            strSortBy = " order by Date DESC"
        }
        else if sortBy == 3 {
            strSortBy = " order by Date ASC"
        }
        else if sortBy == 4 {
            strSortBy = " order by totalPages DESC"
        }
        
        let queryString = "SELECT doc.*, count(page.Id) as totalPages FROM Documents doc left outer join Pages page on page.DocumentId = doc.Id where doc.FolderId = \(folderId) AND(\(strSearch)) group by doc.Id"+"\(strSortBy)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return arrDocuments
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let item : TaskModel = TaskModel()
            arrDocuments.append(item)
        }
        return arrDocuments
    }
    func getDocumentId(name : String) -> Int {
        
        var docId : Int = 0
        
        let queryString = "SELECT Id FROM Documents where Name = '\(name)'"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return 0
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            docId = Int(sqlite3_column_int(stmt, 0))
        }
        return docId
    }
    func checkDocumentNameExists(name : String, Id : Int) -> String {
        
        var docName : String = ""
        
        let queryString = "SELECT Name FROM Documents where Name = '\(name)' and FolderId = \(Id)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return docName
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            docName = String(cString: sqlite3_column_text(stmt, 0))
        }
        return docName
    }
    func getFolderName(Id : Int) -> String {
        
        var folderName : String = ""
        
        let queryString = "SELECT Name FROM Folders where Id = \(Id)"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return folderName
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            folderName = String(cString: sqlite3_column_text(stmt, 0))
        }
        return folderName
    }
    func checkFolderNameExist(name : String) -> String {
        
        var folderName : String = ""
        
        let queryString = "SELECT Name FROM Folders where Name = '\(name)'"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return folderName
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            folderName = String(cString: sqlite3_column_text(stmt, 0))
        }
        return folderName
    }
    func AddTask(taskDetail : TaskModel) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO Tasks (Title, Description, Task_Type, Date_Created, Start_Time, End_Time, Task_Date, Task_Status , Project_Name , UserId, TotalTaskHours) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, taskDetail.Title.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, taskDetail.Description.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, taskDetail.Task_Type.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, taskDetail.Date_Created.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, taskDetail.Start_Time.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, taskDetail.End_Time.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, taskDetail.Task_Date.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, taskDetail.Task_Status.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 9, taskDetail.Project_Name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 10, taskDetail.UserId.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 11, taskDetail.TotalTaskHours.utf8String, -1, nil)
   
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    func UpdateTaskOfID(taskDetail : TaskModel, taskID : Int)
    {
           var updateStatement: OpaquePointer? = nil
           let updateStatementString = "UPDATE Tasks SET Title = '\(taskDetail.Title)',Description = '\(taskDetail.Description)',Task_Type = '\(taskDetail.Task_Type)',Date_Created = '\(taskDetail.Date_Created)',Start_Time = '\(taskDetail.Start_Time)',End_Time = '\(taskDetail.End_Time)',Task_Date = '\(taskDetail.Task_Date)', Task_Status = '\(taskDetail.Task_Status)',Project_Name = '\(taskDetail.Project_Name)', TotalTaskHours = '\(taskDetail.TotalTaskHours)' WHERE Id = '\(taskID)';"
           
           if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
              
              if sqlite3_step(updateStatement) == SQLITE_DONE {
                  print("Successfully updated record.")
              } else {
                  print("Could not update record.")
              }
          } else {
              print("UPDATE statement could not be prepared")
          }
          sqlite3_finalize(updateStatement)
          
       }

    func deleteThisTask(Id : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Tasks WHERE Id = \(Id);"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }

    func insertDocument(folderId: Int, name: NSString) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO Documents (FolderId, Name, Date) VALUES (?, ?, ?);"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
  
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let now : NSString = dateformatter.string(from: NSDate() as Date) as NSString
            
            sqlite3_bind_int(insertStatement, 1, Int32(folderId))
            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, now.utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    func insertPages(folderId: Int, docId: Int, OriginalURL: NSString, EditedURL: NSString, EditedWFURL: NSString) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO Pages (FolderId, DocumentId, OriginalURL, EditedURL, EditedOriginalURL) VALUES (?, ?, ?, ?, ?);"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(folderId))
            sqlite3_bind_int(insertStatement, 2, Int32(docId))
            sqlite3_bind_text(insertStatement, 3, OriginalURL.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, EditedURL.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, EditedURL.utf8String, -1, nil)
        
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }

        sqlite3_finalize(insertStatement)
    }
    func deletePages(Ids : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Pages WHERE DocumentId In (\(Ids));"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    func deletePagesWithFolderIds(Ids : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Pages WHERE FolderId In (\(Ids));"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    func deleteDocument(Ids : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Documents WHERE Id In (\(Ids));"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    func deleteDocumentsWithFolderIds(Ids : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Documents WHERE FolderId In (\(Ids));"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    func deleteFolders(Ids : String) {
        var deleteStatement: OpaquePointer? = nil
        let deleteStatementStirng = "DELETE FROM Folders WHERE Id In (\(Ids));"
        
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
    }
}
