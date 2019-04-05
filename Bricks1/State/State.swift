import ReSwift
import FirebaseUI


struct AppState: StateType {
    var firPushNotifToken : String?
    var firToken: String?
    var authToken: String?
    var currentUser: User?
    
    var userId: Int?
    var username: String?
    var image: UIImage?
    
    var tasks: [Task] = [Task]()
    var teams: [Team] = [Team]()
    var displayTask: Task?
    var pointsTotal: Int = 0
    var weeklyGrades: [Int] = Array(repeating: 0, count: 7)
    var streak: Int = 0
    var rank: Int = 0
    var totalUsers: Int = 0
    var consistency: Double = 0.0
    
    var loggedIn: Bool = false
    var fetchingLogIn: Bool = false
    var tomorrowTaskChosen: Bool = false
}
