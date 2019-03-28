import ReSwift
import FirebaseUI


struct AppState: StateType {
    var googleToken: String?
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
    
    var loggedIn: Bool = false
    var fetchingLogIn: Bool = false
    var tomorrowTaskChosen: Bool = false
}
