import UIKit
import ReSwift
import Firebase
import Charts


class LandingVC: UIViewController, UITableViewDataSource, StoreSubscriber, MessagingDelegate, UITableViewDelegate, FetchDelegate {
    
    // FetchDelegate protocol
    func confirmation(title: String, message: String) {
        Alerts.confirmation(self, title: title, message: message)
    }
    
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var pointsTotalLabel: UILabel!
    
    @IBOutlet var rank: UILabel!
    @IBOutlet var totalUsers: UILabel!
    
    @IBOutlet var barChart: BarChartView!
    @IBOutlet var pieChart: PieChartView!
    
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var taskButtonLabel: UILabel!
    @IBOutlet var yourTaskLabel: UILabel!
    @IBOutlet var tomorrowLabel: UILabel!
    @IBOutlet var yourGrade: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self)
        
        allowNotifications()
        trackLogins()
        
        Fetch.delegate = self
        
        configureTableView()
        configureViews()
        configureFirebase()
        
        // set up Firestore threads for each member on each team
        _ = Threads()
        
        updateBarChart(store.state.weeklyGrades, barChartView: barChart)
        updatePieChart(store.state.streak, pieChartView: pieChart)
    }
    
    func configureTableView() {
        tableView.delegate = self
        
        tableView.dataSource = self as UITableViewDataSource
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    func configureFirebase() {
        Messaging.messaging().delegate = self
    }
    
    func configureViews() {
        // configure icon image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        
        // configure taskButton image
        taskButton.layer.cornerRadius = taskButton.frame.height / 2
        taskButton.layer.masksToBounds = false
        taskButton.clipsToBounds = true
        
        // config yourTask labels
        yourGrade.text = ""
        tomorrowLabel.isHidden = true
    }
    
    func trackLogins() {
        // add a login counter to userDefaults
        if defaults.object(forKey: "firstLogin") == nil {
            Alerts.welcomeMenu(self)
            defaults.set(true, forKey: "firstLogin")
        }
    }
    
    /// part of the StoreSubscriber Protocol
    /// TODO seems inefficient that there is a reload on every state change
    func newState(state: AppState) {
        print("LANDING_VC: reloading data.")
        setTaskButtons(state)
        tableView.reloadData()
        pointsTotalLabel.text = String(state.pointsTotal) + " pts"
        // set which task is being looked at
        
        yourTaskLabel.text = state.displayTask?.description ?? "What's your top task today?"
        yourGrade.text = ""
        
        if let grade = state.displayTask?.grade {
            yourGrade.text = String(grade)
        }
        
        
        if store.state.image != nil {
            profileImage.image = store.state.image
        }
        
        updateBarChart(state.weeklyGrades, barChartView: barChart)
        updatePieChart(state.streak, pieChartView: pieChart)
        
        print("RANK: ", state.rank)
        rank.text = "\(state.rank)"
        totalUsers.text = "/ \(state.totalUsers)"
    }
    
    /// rerun get requests
    @objc func refreshData(_ sender: Any) {
        Fetch.refreshData(refreshControl: refreshControl)
    }

    
    // USER INTERACTIVITY
    
    @IBAction func triggerTaskAction(_ sender: Any) {
        var taskChosen = false
        var taskGraded = false
        
        if store.state.displayTask?.description != nil {taskChosen = true}
        if store.state.displayTask?.grade != nil {taskGraded = true}
        
        switch (taskChosen, taskGraded, store.state.tomorrowTaskChosen) {
        case (false, false, false):
            Alerts.chooseTask(self, dueDelta: 0)
        case (true, false, false):
            Alerts.gradeTask(self)
        case (true, true, false):
            Alerts.chooseTask(self, dueDelta: 1)
        case (true, false, true):
            Alerts.chooseTask(self, dueDelta: 1)
        default:
            break
        }
    }
    
    @IBAction func triggerGiveFeedbackAlert(_ sender: Any) {
        Alerts.giveFeedback(self, message: "How can I improve this app?")
    }
    
    // TABLE VIEW
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")! as! HeaderCell
        cell.teamName.text = store.state.teams[section].name
        cell.button.tag = section
//        cell.button.addTarget(self, action: #selector(presentTeamVC), for: .touchUpInside)
        cell.button.addTarget(self, action: #selector(inviteFriend), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func inviteFriend(_ sender: UIButton) {
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

        cell.username.text = member.username
        cell.taskDescription.text = member.displayTask?.description ?? ""
        
        cell.tomorrowLabel.isHidden = true
        if member.displayTask?.dueDate == naiveDate(delta: 1) { cell.tomorrowLabel.isHidden = false }
        
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
    
    // UPDATE UI BASED ON STATE
    func setTaskButtons(_ state: AppState) {
        var taskChosen = false
        var taskGraded = false
        
        if state.displayTask?.description != nil {taskChosen = true}
        if state.displayTask?.grade != nil {taskGraded = true}
        
        switch (taskChosen, taskGraded, state.tomorrowTaskChosen) {
        case (false, false, false):
            taskButtonLabel.text = "Choose"
            
            taskButton.setImage(UIImage(named: "plus-30"), for: .normal)
        case (true, false, false):
            taskButtonLabel.text = "Grade"
            taskButton.setImage(UIImage(named: "pass-fail-25"), for: .normal)
        case (true, true, false):
            taskButtonLabel.text = "Tomorrow"
            taskButton.setImage(UIImage(named: "plus-30"), for: .normal)
        case (true, false, true):
            taskButtonLabel.text = "Change"
            taskButton.setImage(UIImage(named: "pencil-25"), for: .normal)
            tomorrowLabel.isHidden = false
        default:
            break
        }
    }
}


