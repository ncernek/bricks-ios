import ReSwift


func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    print("ACTION: ", String(describing: action).prefix(100))
    
    switch action {
    
    case let action as SaveTeams:
        state.teams = action.teams
        Threads.makeThreads(action.teams)
    
    case let action as SaveFIRPushNotifToken:
        state.firPushNotifToken = action.token
        
    case let action as SaveFIRToken:
        state.firToken = action.firToken
    
    case let action as SaveUserDetails:
        state.currentUser = action.currentUser
    
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
    
    case let action as SaveDisplayTask:
        state.displayTask = action.task
        if action.task.dueDate > naiveDate() { state.tomorrowTaskChosen = true }
    
    case let action as SaveTasks:
        state.tasks = action.tasks
        
    case let action as SaveUnreadMessageCount:
        state.teams[action.teamIndex].members[action.memberIndex].unreadMessageCount = action.unreadMessageCount
    
    default:
        break
    }
    return state
}
