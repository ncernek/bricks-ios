import UIKit
import ReSwift


class TeamVC : UIViewController, UITableViewDataSource {
    var team: Team?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = team?.name
        
        // nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add-friend-30"), style: .plain, target: self, action: #selector(inviteFriend))

        
        // Table View
        tableView.dataSource = self as UITableViewDataSource
        tableView.allowsSelection = false
        
    }
    
    @objc func inviteFriend(_ sender: Any) {
        print("HELLO")
        Alerts.inviteFriend(self, team: team!)
    }
    
    // USER INTERACTIVITY
    @IBAction func triggerInviteFriend(_ sender: Any) {
        Alerts.inviteFriend(self, team: team!)
    }
    
    @IBAction func triggerFeedback(_ sender: Any) {
        Alerts.giveFeedback(self, message: "What stats do you want to see?")
    }
    
    
    // Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team!.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberCell
        
        let member = team!.members[indexPath.row]
        
        cell.username.text = member.username
        cell.pointsTotal.text = String(member.pointsTotal) + " pts"
        
        return cell
    }
}
