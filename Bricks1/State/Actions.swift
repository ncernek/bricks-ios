import ReSwift
import FirebaseUI

struct ActionSaveFriendTasks: Action {
    let friendTasks: [Task]
}

struct SaveFIRPushNotifToken: Action {
    let token: String
}
struct SaveFIRToken: Action {
    let firToken: String
}

struct ActionSaveUsername: Action {
    let username: String
}

struct ActionSaveAuthTokenAndUID: Action {
    let authToken: String
    let userId: Int
}

struct FetchingLogin: Action {}

struct ActionLogOut: Action {}

struct ActionSaveTeams: Action {
    let teams: [Team]
}

struct ActionSaveImage: Action {
    let image: UIImage
}

struct SaveTeams: Action {
    let teams: [Team]
}

struct SaveStats: Action {
    let pointsTotal: Int
    let weeklyGrades: [Int]
    let streak: Int
    let rank: Int
    let totalUsers: Int
    let consistency: Int
    let countGradedTasks: Int
    let assistance: Int
    let todayAssist: Bool
}

struct SaveLatestTask: Action {
    let task: Task?
    init(task: Task? = nil) {
        self.task = task
    }
}

struct SaveTasks: Action {
    let tasks: [Task]
}

struct SaveUnreadMessageCount: Action {
    let teamIndex: Int
    let memberIndex: Int
    let unreadMessageCount: Int
}

struct SaveUserDetails: Action {
    let currentUser: User // FUI
}

struct LoginCompleted: Action {}

struct FlipAssistArrow: Action {}
