//
//  NotificationTableCell.swift
//  TaskManager
//
//  Created by Hima on R 2/02/07.
//  Copyright © Reiwa 2 Hima. All rights reserved.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    @IBOutlet var lblTime: UILabel!

    @IBOutlet var lblTitle: UILabel!

    @IBOutlet var lblDesc: UILabel!

    @IBOutlet var lblTaskType: UILabel!

    @IBOutlet var vwLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
