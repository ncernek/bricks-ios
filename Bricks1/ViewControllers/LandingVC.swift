import UIKit
import ReSwift
import Firebase
import Charts


class LandingVC: UIViewController, UITableViewDataSource, StoreSubscriber, UITableViewDelegate, FetchDelegate {
    
    // FetchDelegate protocol
    func confirmation(title: String, message: String) {
        Alerts.confirmation(self, title: title, message: message)
    }
    
    typealias StoreSubscriberStateType = AppState
    
    @IBOutlet var profileImage: UIButton!
    @IBOutlet var createTeamButton: UIButton!
    
    // stats
    @IBOutlet var countGradedTasks: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var consistency: UILabel!
    
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
        
        // set up Firestore threads for each member on each team
        _ = Threads()
        
        updateBarChart(store.state.weeklyGrades, barChartView: barChart)
        updatePieChart(store.state.streak, pieChartView: pieChart)
    }
    
    /// show navbar for other VCs
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// hide navbar for landing VC
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func configureTableView() {
        tableView.delegate = self
        
        tableView.dataSource = self as UITableViewDataSource
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    func configureViews() {
        // configure icon image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
        
        // configure add team button
        createTeamButton.layer.cornerRadius = createTeamButton.frame.height / 2
        createTeamButton.layer.masksToBounds = false
        createTeamButton.clipsToBounds = true
        
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
        
        // set which task is being looked at
        
        yourTaskLabel.text = state.latestTask?.description ?? "What's your top task today?"
        yourGrade.text = ""
        
        // TODO remove this
        if let grade = state.latestTask?.grade {
            yourGrade.text = String(grade)
        }
        
        
        if store.state.image != nil {
            profileImage.setBackgroundImage(store.state.image, for: .normal)
        }
        
        updateBarChart(state.weeklyGrades, barChartView: barChart)
        updatePieChart(state.streak, pieChartView: pieChart)
        
        // stats
        countGradedTasks.text = "tasks: \(state.countGradedTasks)"
        consistency.text = "\(state.consistency) tasks/day"
        rank.text = "rank: \(state.rank) of \(state.totalUsers)"
    }
    
    /// rerun get requests
    @objc func refreshData(_ sender: Any) {
        Fetch.refreshData(refreshControl: refreshControl)
    }

    
    // USER INTERACTIVITY
    
    @IBAction func triggerCreateTeam(_ sender: Any) {
        Alerts.createTeam(self)
    }
    
    
    @IBAction func triggerInfo(_ sender: Any) {
        Alerts.info(self, title: "Calculations explained", message: "A task is only counted if you grade it.\n\ntasks/day : all tasks divided by number of days you've used the app.\n\nrank : tasks/day compared to all other users.\n\ntasks : total number of tasks")
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
        cell.consistency.text = String(member.consistency)
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
    

    func setTaskButtons(_ state: AppState) {
        taskButton.removeTarget(nil, action: nil, for: .allEvents)
        var taskChosen = false
        var taskGraded = false
        var todayTaskGraded = false
        
        if let latestTask = store.state.latestTask {
            taskChosen = true
            if latestTask.grade != nil {
                taskGraded = true
                if latestTask.dueDate >= naiveDate() { todayTaskGraded = true }
            }
            if latestTask.dueDate > naiveDate() { todayTaskGraded = true }
        }
        print("CONDITIONS: ", taskChosen, taskGraded, todayTaskGraded)
        switch (taskChosen, taskGraded, todayTaskGraded) {
        // no task
        case (false, _, _):
            taskButton.tag = 0
            taskButton.addTarget(self, action: #selector(_chooseTask), for: .touchUpInside)
            taskButtonLabel.text = "Choose"
            taskButton.setImage(UIImage(named: "plus-30"), for: .normal)
            
        // today or yester task but not graded
        case (true, false, false):
            taskButton.addTarget(self, action: #selector(_gradeTask), for: .touchUpInside)
            taskButtonLabel.text = "Grade"
            taskButton.setImage(UIImage(named: "pass-fail-25"), for: .normal)
            
        // yester task graded
        case (true, true, false):
            taskButton.tag = 0
            taskButton.addTarget(self, action: #selector(_chooseTask), for: .touchUpInside)
            taskButtonLabel.text = "Choose"
            taskButton.setImage(UIImage(named: "plus-30"), for: .normal)
            
        // today task graded
        case (true, true, true):
            taskButton.tag = 1
            taskButton.addTarget(self, action: #selector(_chooseTask), for: .touchUpInside)
            taskButtonLabel.text = "Tomorrow"
            taskButton.setImage(UIImage(named: "plus-30"), for: .normal)
            
        // tomorrow task
        case (true, false, true):
            taskButton.tag = 1
            taskButton.addTarget(self, action: #selector(_chooseTask), for: .touchUpInside)
            taskButtonLabel.text = "Change"
            taskButton.setImage(UIImage(named: "pencil-25"), for: .normal)
            
        default:
            break
        }
    }
    
    @objc func _chooseTask(_ sender: UIButton) {
        Alerts.chooseTask(self, dueDelta: sender.tag)
    }
    
    @objc func _gradeTask(_ sender: UIButton) {
        Alerts.gradeTask(self)
    }
    
}


