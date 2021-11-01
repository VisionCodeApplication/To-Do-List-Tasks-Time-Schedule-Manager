//
//  TaskModel.swift
//  TaskManager
//
//  Created by Hima on 28/01/20.
//  Copyright © 2020 Hima. All rights reserved.
//

import UIKit

class TaskModel: NSObject {

    var ID : Int = 0
    var Title: NSString = ""
    var Description: NSString = ""
    var Task_Type: NSString = TaskTypeEnum.Task.rawValue as NSString
    var Date_Created: NSString = ""
    var Start_Time: NSString = ""
    var End_Time: NSString = ""
    var Task_Date: NSString = ""
    var Task_Status: NSString = TaskStatusEnum.const_Pending.rawValue as NSString
    var Project_Name: NSString = ""
    var UserId: NSString = ""
    var TotalTaskHours: NSString = ""
    var task_month: NSString = ""
    
}
