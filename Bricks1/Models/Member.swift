
struct Member {
    let username: String
    let userId: Int
    var memberId: Int
    var pointsTotal: Int
    var displayTask: Task? = nil
    var tasks: [Task]
    var unreadMessageCount: Int = 0
    var consistency: Int = 0
    
    init(username: String, userId: Int, memberId: Int, pointsTotal: Int, displayTask: Task? = nil, tasks: [Task] = [Task](), consistency: Int) {
        self.username = username
        self.userId = userId
        self.memberId = memberId
        self.pointsTotal = pointsTotal
        self.displayTask = displayTask
        self.tasks = tasks
        self.consistency = consistency
    }
    
    func toDict() -> [String: Any?] {
        var task_list = [[String: Any]]()
        for task in self.tasks {
            task_list.append(task.toDict())
        }
        return [
            "username": self.username,
            "user_id": self.userId,
            "member_id": self.memberId,
            "points_total": self.pointsTotal,
            "display_task": self.displayTask,
            "tasks": task_list,
            "consistency": self.consistency
        ]
    }
    
    static func placeholder() -> Member {
        return Member(
            username: "placeholder",
            userId: 0,
            memberId: 0,
            pointsTotal: 0,
            displayTask: nil,
            tasks: [Task](),
            consistency: 0
        )
    }
    
    static func fromDict(_ member: [String: Any?]) -> Member {
        var tasks = [Task]()
        var displayTask: Task? = nil
        for taskDict in member["tasks"] as! [[String: Any?]] {
            let task = Task.fromDict(taskDict)
            tasks.append(task)
        }
        // determine displayTask
        // assume tasks are already sorted
        if tasks.count > 0 {
            if tasks[0].dueDate >= naiveDate(delta: 0) {
                displayTask = tasks[0]
            }
        }
        
        return Member(
            username: member["username"] as! String,
            userId: member["user_id"] as! Int,
            memberId: member["member_id"] as! Int,
            pointsTotal: member["points_total"] as! Int,
            displayTask: displayTask,
            tasks: tasks,
            consistency: member["consistency"] as! Int
        )
    }
}
