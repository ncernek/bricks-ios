import UIKit


class MemberCell: UITableViewCell {
    
    @IBOutlet var username: UILabel!
    @IBOutlet var pointsTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
