
import UIKit
import iOSDropDown

class TaskTableCell: UITableViewCell {
    
    @IBOutlet var lblTime : UILabel!

    @IBOutlet var lblEndTime : UILabel!
   
    @IBOutlet var lblTitle : UILabel!
    
    @IBOutlet var btnTaskType : UIButton!
    
    @IBOutlet var imgViewLeftDash: UIImageView!
    
    @IBOutlet var vwTaskBG: UIView!

    @IBOutlet var btnTaskStatusEdit: UIButton!
    
    @IBOutlet var progressbar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
