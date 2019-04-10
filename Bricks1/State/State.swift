import ReSwift
import FirebaseUI


struct AppState: StateType {
    var firPushNotifToken : String?
    var firToken: String?
    var authToken: String?
    var firUser: User?
    var appUser: AppUser?
    
    var userId: Int?
    var username: String?
    var image: UIImage?
    
    var tasks: [Task] = [Task]()
    var teams: [Team] = [Team]()
    var latestTask: Task? = nil
    var pointsTotal: Int = 0
    var weeklyGrades: [Int] = Array(repeating: 0, count: 7)
    var streak: Int = 0
    var rank: Int = 0
    var totalUsers: Int = 0
    var consistency: Int = 0
    var countGradedTasks: Int = 0
    var assistance: Int = 0
    var todayAssist: Bool = false
    var monthlyGradedTasks: Int = 0
    var monthlyGoal: Int?
    
    var loggedIn: Bool = false
    var fetchingLogIn: Bool = false
    
    var totalUnreadMessageCount: Int = 0
}
