import ReSwift


func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    print("ACTION: ", String(describing: action).prefix(100))
    
    switch action {
    
    case let action as SaveTeams:
        state.teams = action.teams
        Threads.makeThreads(action.teams)
        state.totalUnreadMessageCount = 0
    
    case let action as SaveFIRPushNotifToken:
        state.firPushNotifToken = action.firPushNotifToken
        
    case let action as SaveFIRToken:
        state.firToken = action.firToken
    
    case let action as SaveFIRUser:
        state.firUser = action.firUser
    
    case let action as SaveAppUser:
        state.appUser = action.appUser
    
    case let action as ActionSaveImage:
        state.image = action.image
        
    case _ as FetchingLogin:
        state.fetchingLogIn = true
        
    case let action as ActionSaveAuthTokenAndUID:
        state.authToken = action.authToken
        state.userId = action.userId
    
    case _ as LoginCompleted:
        state.loggedIn = true
        state.fetchingLogIn = false
        setVCforLogin(loggedIn: true)
        
    case _ as ActionLogOut:
        state = AppState()
    
    case let action as SaveStats:
        state.pointsTotal = action.pointsTotal
        state.weeklyGrades = action.weeklyGrades
        state.streak = action.streak
        state.rank = action.rank
        state.totalUsers = action.totalUsers
        state.consistency = action.consistency
        state.countGradedTasks = action.countGradedTasks
        state.assistance = action.assistance
        state.todayAssist = action.todayAssist
        state.monthlyGradedTasks = action.monthlyGradedTasks
    
    case let action as SaveLatestTask:
        state.latestTask = action.task

    case let action as SaveTasks:
        state.tasks = action.tasks
        
    case let action as SaveUnreadMessageCount:
        var previousCount = state.teams[action.teamIndex].members[action.memberIndex].unreadMessageCount
        state.totalUnreadMessageCount = state.totalUnreadMessageCount + action.unreadMessageCount - previousCount
        state.teams[action.teamIndex].members[action.memberIndex].unreadMessageCount = action.unreadMessageCount
        
        // update the badge app icon
        UIApplication.shared.applicationIconBadgeNumber = state.totalUnreadMessageCount

    
    case _ as FlipAssistArrow:
        state.todayAssist = true

    case let action as UpdateMonthlyGoal:
        state.monthlyGoal = action.goal
        
    case let action as UpdateMonthlyContentGoal:
        state.monthlyContentGoal = action.goal
        
    default:
        break
    }
    return state
}
