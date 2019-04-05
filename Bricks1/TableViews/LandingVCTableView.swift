import UIKit

class HeaderCell: UITableViewCell {
    @IBOutlet var teamName: UILabel!
    @IBOutlet var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class TaskCell: UITableViewCell {
    @IBOutlet var username: UILabel!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var grade: UILabel!
    @IBOutlet var tomorrowLabel: UILabel!
    @IBOutlet var consistency: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // configure unread messages label
        grade.layer.cornerRadius = grade.frame.height / 2
        grade.layer.masksToBounds = false
        grade.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
