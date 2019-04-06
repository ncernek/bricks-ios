import SwiftDate
import FirebaseFirestore
import PromiseKit

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
        
        // move the latest task (in FS) to the tasks collection
        let db = Firestore.firestore()
        let currentUserPath = ["users", String(store.state.currentUser!.uid)].joined(separator: "/")

        self.archivePreviousTask(db, currentUserPath: currentUserPath)
            .ensure {
                // save new task to latest task in Firestore
                db.document(currentUserPath).setData(["latestTask": task.toDict()], merge: true)
            }.catch { error in
                print(error.localizedDescription)
            }
        
        // save task to Postgres
        Fetch.putTask(task)
    }
    
    static func updateTaskGrade(_ grade: Int) {
        let task = store.state.latestTask!.update(grade: grade)
        Fetch.putTask(task)
    }
    
    /// move latestTask (in FS) to tasks collection
    static func archivePreviousTask(_ db: Firestore, currentUserPath: String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            db.document(currentUserPath).getDocument() {(document, error) in
                if let document = document {
                    let latestTask = document.data()!["latestTask"] as! [String: Any]
                    print("document data:", latestTask)
                    let tasksRef = db.collection([currentUserPath, "tasks"].joined(separator: "/"))
                    tasksRef.addDocument(data: latestTask)
                } else {
                    print("Document does not exist")
                }
                return seal.fulfill(true)
            }
        }
    }
}

