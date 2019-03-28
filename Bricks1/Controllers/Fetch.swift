import Foundation
import PromiseKit
import SwiftDate


class Fetch {
    static let config = AppConfig()
    
    // TOP LEVEL METHODS
    
    /// get user data at login: authToken, Teams
    class func login(_ googleToken: String) {
        store.dispatch(FetchingLogin())
        promiseAuthToken(googleToken)
            .then { _ in
                self.promisePutAppUser(["username": store.state.currentUser?.displayName!])
            }.then { _ in
                self.promiseGetTasks()
            }.then { _ in
                self.promiseGetTeams()
            }.then { _ in
                self.promiseGetStats()
            }.ensure {
                store.dispatch(LoginCompleted())
            }.catch { error in
            // TODO create an alert with the error
            print("ERROR RUNNING login(): ", error.localizedDescription)
            print("FULL ERROR OBJECT", error)
        }
    }
    
    class func refreshData(refreshControl: UIRefreshControl? = nil) {
        promiseAuthToken(store.state.authToken!)
            .then {_ in
                self.promiseGetTasks()
            }.then {_ in
                self.promiseGetStats()
            }.then {_ in
                self.promiseGetTeams()
            }.ensure{
                if refreshControl != nil {
                    refreshControl?.endRefreshing()
                }
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    
    /// put task data to backend, returns a task id
    class func putTask(_ task: Task) {
        promiseAuthToken(store.state.authToken!)
            .then { _ in
                self.promisePutTask(task)
            }.then { _ in
                self.promiseGetStats()
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
            }
        }
    
    class func putAppUser(_ params: [String: Any]) {
        promiseAuthToken(store.state.googleToken!)
            .then{ _ in
                self.promisePutAppUser(params)
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    class func putTeam(_ name: String) {
        promiseAuthToken(store.state.googleToken!)
            .then { _ in
                self.promisePutTeam(name)
            }.then { _ in
                self.promiseGetTeams()
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    /// send phone number to backend to invite friend to this team
    class func postInvitation(phoneNumber: String, teamId: Int) {
        promiseAuthToken(store.state.googleToken!)
            .then { _ in
                self.promisePostInvitation(phoneNumber: phoneNumber, teamId: teamId)
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    class func joinTeam(code: String) {
        promiseAuthToken(store.state.googleToken!)
            .then { _ in
                self.promiseJoinTeam(code: code)
            }.then { _ in
                self.promiseGetTeams()
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
            }
        }
    
    class func postFeedback(_ text: String) {
        self.promiseAuthToken(store.state.googleToken!)
            .then { _ in
                self.promisePostFeedback(text)
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    class func getImage(_ url: URL) {
        self.promiseGetImage(url)
    }

    
    // PROMISES

    class func promiseAuthToken(_ googleToken: String) -> Promise<Bool> {
        return firstly {
            self.request(googleToken, method: "GET", url: config.URL_AUTH_TOKEN)
        }.map { (data: Data?, _) in
            self.responseGetAuthToken(data: data!)
        }
    }
    
    class func promisePutTask(_ task: Task) -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "PUT", params: task.toDict(), url: config.URL_TASK)
            }.map { (data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any?]
                    let task = Task.fromDict(json)
                    store.dispatch(SaveDisplayTask(task: task))
                    return true
                }
            }.get { didSucceed in
                if didSucceed && task.grade == nil {
                    self.triggerConfirmation(title: "Success!", message: "I'll follow up with you tonight to check on your progress.")
                } else if didSucceed {
                    let points = store.state.displayTask!.pointsEarned!
                    self.triggerConfirmation(title: "+\(points) pts earned!", message: "Keep up the good work.")
                }
        }
    }
    
    class func promisePutAppUser(_ params: [String: Any]) -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "PUT", params: params, url: config.URL_APP_USER)
            }.map { (data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {_ in
                    return true
                }
        }
    }
    
    class func promisePutTeam(_ name: String) -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "PUT", params: ["name" : name], url: config.URL_TEAM)
            }.map { (data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {_ in
                self.triggerConfirmation(title: "Success!", message: "Team created.")
                    return true
            }
        }
    }
    
    class func promisePostInvitation(phoneNumber: String, teamId: Int) -> Promise<Bool>{
        let authToken = store.state.authToken!
        let params: [String : Any] = [
            "phone_number": phoneNumber,
            "team_id": teamId
            ]
        return firstly {
            self.request(authToken, method: "POST", params: params, url: config.URL_INVITE)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    self.triggerConfirmation(title: "Success!", message: json["message"] as? String)
                    return true
                }
        }
    }
    
    class func promiseJoinTeam(code: String) -> Promise<Bool> {
        let authToken = store.state.authToken!
        let params: [String : Any] = [
            "code": code,
        ]
        return firstly {
            self.request(authToken, method: "POST", params: params, url: config.URL_JOIN)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let name = json["name"] as! String
                    self.triggerConfirmation(title: "Success!", message: "You just joined: \(name).")
                    return true
                }
        }
    }
    
    class func promisePostFeedback(_ text: String) -> Promise<Bool> {
        let authToken = store.state.authToken!
        let params: [String : Any] = [
            "text": text,
            ]
        return firstly {
            self.request(authToken, method: "POST", params: params, url: config.URL_FEEDBACK)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {_ in
                    self.triggerConfirmation(title: "Thanks!", message: "I'll take this feedback into account for later versions.")
                    return true
                }
        }
    }
    
    class func promiseGetImage(_ url: URL) {
        self.request("NONE", method: "GET", url: url)
            .done {(data: Data?, response: URLResponse?) in
                store.dispatch(ActionSaveImage(image: UIImage(data: data!)!))
            }.catch { error in
                // TODO make some sort of error alert
                print(error.localizedDescription)
        }
    }
    
    /// get all user's teams, their members, and their tasks. includes current user
    class func promiseGetTeams() -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "GET", url: config.URL_TEAM)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    var teams = [Team]()
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any?]]
                    for team in json {
                        teams.append(Team.fromDict(team))
                    }
                    
                    teams.sort() {(a: Team, b: Team) -> Bool in
                        if a.members.count > b.members.count { return true }
                        else { return false }
                    }
                    
                    store.dispatch(SaveTeams(teams: teams))
                    return true
                }
        }
    }
    
    /// get current user's tasks
    class func promiseGetTasks() -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "GET", url: config.URL_TASK)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:Any?]]
                    
                    if let json = json {
                        var tasks = [Task]()
                        for taskDict in json {
                            let task = Task.fromDict(taskDict)
                            tasks.append(task)
                        }
                        store.dispatch(SaveTasks(tasks: tasks))
                        if tasks.count > 0 {
                            if tasks[0].dueDate >= naiveDate(delta: 0) {
                                store.dispatch(SaveDisplayTask(task: tasks[0]))
                            }
                        }
                    }
                    return true
                }
        }
    }
    
    class func promiseGetStats() -> Promise<Bool> {
        let authToken = store.state.authToken!
        return firstly {
            self.request(authToken, method: "GET", url: config.URL_STATS)
            }.map {(data: Data?, response: URLResponse?) in
                self.handleResponse(data: data!, response: response!) {data in
                    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any?]
                    let pointsTotal = json["points_total"] as! Int
                    let weeklyGrades = json["weekly_grades"] as! [Int]
                    let streak = json["streak"] as! Int
                    store.dispatch(SaveStats(pointsTotal: pointsTotal, weeklyGrades: weeklyGrades, streak: streak))
                    return true
                }
        }
    }
        
    // REQUESTS
    
    // in the future try to implement background requests
    // https://stackoverflow.com/a/41191971/5791460
    // https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html
    // https://github.com/mxcl/PromiseKit/blob/master/Documentation/Appendix.md
    
    class func request(_ token: String, method: String, params: [String: Any]? = nil, url: URL) -> Promise<(data: Data, response: URLResponse)> {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let timezone = TimeZone.current.description.components(separatedBy: " ")[0]
        request.setValue(timezone, forHTTPHeaderField: "TZ")
        
        if let params = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        }
        
        return URLSession.shared.dataTask(.promise, with: request as URLRequest)
    }
    
    // RESPONSE HANDLERS
    
    /// let this fail silently if the authToken is still valid. it is easier to try to get new authTokens too often
    /// than to have catches for every query that could fail
    class func responseGetAuthToken(data: Data) -> Bool {
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject?]
        if let authToken = json["auth_token"] as? String {
            let authToken =  "Token \(authToken)"
            let userId = json["user_id"] as! Int
            store.dispatch(ActionSaveAuthTokenAndUID(authToken: authToken, userId: userId))
            return true
        }
        return false
    }
    
    /// TODO standardize error messages sent by API
    class func handleResponse(data: Data, response: URLResponse, handler: (Data) -> Bool ) -> Bool {
        let httpResponse = response as! HTTPURLResponse
        if httpResponse.statusCode == 200 {
            return handler(data)
        } else if httpResponse.statusCode == 400 {
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any?]
            print("FETCH: STATUS CODE: ", httpResponse.statusCode)
            print("FETCH: ERROR MESSAGE: ", json["message"]! as! String)
            self.triggerConfirmation(title: "Error", message: json["message"]! as? String)
        } else if httpResponse.statusCode == 401 {
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any?]
            print("FETCH: STATUS CODE: ", httpResponse.statusCode)
            print("FETCH: ERROR MESSAGE: ", json["message"]! as! String)
            self.triggerConfirmation(title: "Error", message: json["message"]! as? String)
        } else {
            print("FETCH: ERROR: don't know how to handle it.")
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any?]
            print("FETCH: STATUS CODE: ", httpResponse.statusCode)
            print("FETCH: ERROR MESSAGE: ", json["message"]! as! String)
            self.triggerConfirmation(title: "Error", message: json["message"]! as? String)
        }
        return false
    }
    
    static weak var delegate: FetchDelegate?
    
    class func triggerConfirmation(title: String, message: String? = "") {
            delegate?.confirmation(title: title, message: message!)
    }
}

protocol FetchDelegate: class {
    func confirmation(title: String, message: String)
}
