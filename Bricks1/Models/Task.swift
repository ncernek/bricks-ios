import SwiftDate

struct Task {
    
    var dueDate: DateInRegion
    var taskId: Int?
    var description: String
    var grade: Int?
    var pointsEarned: Int?
    
    func toDict() -> [String: Any] {
        return [
            "task_id": self.taskId,
            "description": self.description,
            "due_date": convertToDateString(self.dueDate),
            "grade": self.grade,
            "points_earned": self.pointsEarned,
        ]
    }
    
    /// update an existing task. returns new Task instance
    mutating func update(description: String? = nil, dueDate: DateInRegion? = nil, grade: Int? = nil) -> Task {
        
        self.description = description ?? self.description
        self.dueDate = dueDate ?? self.dueDate
        self.grade = grade ?? self.grade
        return self
    }
    
    static func fromDict(_ memberTask: [String: Any?]) -> Task {
        
        return Task(
            dueDate: convertToDate(memberTask["due_date"] as! String),
            taskId: memberTask["task_id"] as? Int,
            description: memberTask["description"] as! String,
            grade: memberTask["grade"] as? Int,
            pointsEarned: memberTask["points_earned"] as? Int
        )
    }
    
    static func createNewTask(_ taskDescription: String, dueDelta: Int) {        
        let task = Task(
            dueDate: naiveDate(delta: dueDelta),
            taskId: nil,
            description: taskDescription,
            grade: nil,
            pointsEarned: nil)
        
        Fetch.putTask(task)
    }
    
    static func updateTaskGrade(_ grade: Int) {
        let task = store.state.displayTask!.update(grade: grade)
        Fetch.putTask(task)
    }
}

