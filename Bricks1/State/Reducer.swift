import ReSwift


func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    print("ACTION: ", String(describing: action).prefix(100))
    
    switch action {
    
    case let action as SaveTeams:
        state.teams = action.teams
        Threads.makeThreads(action.teams)
        
    case let action as ActionSaveGoogleToken:
        state.googleToken = action.googleToken
    
    case let action as ActionSaveUsername:
        state.username = action.username
    
    case let action as ActionSaveImage:
        state.image = action.image
        
    case _ as ActionFetchingLogin:
        state.fetchingLogIn = true
        
    case let action as ActionSaveAuthTokenAndUID:
        state.authToken = action.authToken
        state.userId = action.userId
        
        if state.loggedIn == false {
            state.loggedIn = true
            state.fetchingLogIn = false
            switchViewControllers(loggedIn: true)
        }
        
    case _ as ActionLogOut:
        state = AppState()
        switchViewControllers(loggedIn: false)
    
    case let action as SaveStats:
        state.pointsTotal = action.pointsTotal
        state.weeklyGrades = action.weeklyGrades
        state.streak = action.streak
    
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
