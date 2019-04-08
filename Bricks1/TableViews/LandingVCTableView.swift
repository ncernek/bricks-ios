// this file contains the table view extensions of the LandingVC
// as well as the view classes that comprise the table view
import UIKit

extension LandingVC: UITableViewDelegate {

    // header formatting
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")! as! HeaderCell
        cell.teamName.text = store.state.teams[section].name
        cell.button.tag = section
        //        cell.button.addTarget(self, action: #selector(presentTeamVC), for: .touchUpInside)
        cell.button.addTarget(self, action: #selector(_inviteFriend), for: .touchUpInside)
        return cell
    }
    
    @objc func _inviteFriend(_ sender: UIButton) {
        let team = store.state.teams[sender.tag]
        Alerts.inviteFriend(self, team: team)
    }
    //    @objc func presentTeamVC(_ sender: UIButton) {
    //        if let teamVC = storyboard?.instantiateViewController(withIdentifier: "Team") as? TeamVC {
    //            teamVC.team = store.state.teams[sender.tag]
    //            navigationController?.pushViewController(teamVC, animated: true)
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 40)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return store.state.teams.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let team = store.state.teams[section]
        return team.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")! as! TaskCell
        
        let team = store.state.teams[indexPath.section]
        let member = team.members[indexPath.row]
        
        cell.member = member
        cell.username.text = member.username
        cell.consistency.text = "\(member.consistency)%"
        
        // if no task, show a NUDGE button instead
        if let displayTask = member.displayTask {
            cell.taskDescription.text = displayTask.description
            cell.taskDescription.isHidden = false
            cell.nudgeButton.isHidden = true
            cell.nudgeButton.isEnabled = false
        } else {
            cell.taskDescription.isHidden = true
            cell.nudgeButton.isHidden = false
            cell.nudgeButton.isEnabled = true
        }
        
        // check if task is for tomorrow
        if member.displayTask?.dueDate == naiveDate(delta: 1) { cell.tomorrowLabel.isHidden = false
        } else {
            cell.tomorrowLabel.isHidden = true
        }
        
        // count unread messages
        cell.grade.text = ""
        cell.grade.isHidden = true
        cell.username.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        if member.unreadMessageCount > 0 {
            cell.grade.text = String(member.unreadMessageCount)
            cell.grade.isHidden = false
            cell.username.font = UIFont.systemFont(ofSize: 15.0, weight: .heavy)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = store.state.teams[indexPath.section]
        let vc = ChatVC(currentUser: team.currentUser, threadOwner: team.members[indexPath.row], team: team)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


/// cell that contains team name
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

/// cell that contains each user
class TaskCell: UITableViewCell {
    @IBOutlet var username: UILabel!
    @IBOutlet var taskDescription: UILabel!
    @IBOutlet var grade: UILabel!
    @IBOutlet var tomorrowLabel: UILabel!
    @IBOutlet var consistency: UILabel!
    @IBOutlet var nudgeButton: UIButton!
    
    var member: Member!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // configure nudge button
        nudgeButton.layer.cornerRadius = nudgeButton.frame.height / 2
        nudgeButton.layer.masksToBounds = false
        nudgeButton.clipsToBounds = true
        
        // configure unread messages label
        grade.layer.cornerRadius = grade.frame.height / 2
        grade.layer.masksToBounds = false
        grade.clipsToBounds = true
    }
    
    @IBAction func triggerNudge(_ sender: Any) {
        Fetch.nudge(member.memberId)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
