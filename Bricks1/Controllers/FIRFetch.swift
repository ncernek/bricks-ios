import Firebase
import FirebaseFirestore

class FIRFetch {
    
    class func setGoal(_ goal: Int) {
        // this month
        let startOfMonth = naiveDate().dateAtStartOf(.month)
        let endOfMonth = naiveDate().dateAtEndOf(.month)
        let monthString = convertToDateString(startOfMonth)

        // get location in FS
        let db = Firestore.firestore()
        let monthPath = ["users", String(store.state.userId!), "monthly_goals", monthString].joined(separator: "/")
        let monthRef = db.document(monthPath)
        
        // set data
        monthRef.setData([
            "start_date": Timestamp(date: startOfMonth.date),
            "end_date": Timestamp(date: endOfMonth.date),
            "goal": goal
            ], merge: false)
    }
    
    class func getGoal() {
        // this month
        let startOfMonth = naiveDate().dateAtStartOf(.month)
        let monthString = convertToDateString(startOfMonth)
        
        // get location in FS
        let db = Firestore.firestore()
        let monthPath = ["users", String(store.state.userId!), "monthly_goals", monthString].joined(separator: "/")
        let monthRef = db.document(monthPath)
        
        // get data
        monthRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let goal = document.data()!["goal"] as! Int
                store.dispatch(UpdateMonthlyGoal(goal: goal))
            } else {
                print("Month Goal does not exist.")
            }
            
        }
    }
    
    class func setContentGoal(_ goal: String) {
        // this month
        let startOfMonth = naiveDate().dateAtStartOf(.month)
        let endOfMonth = naiveDate().dateAtEndOf(.month)
        let monthString = convertToDateString(startOfMonth)
        
        // get location in FS
        let db = Firestore.firestore()
        let monthPath = ["users", String(store.state.userId!), "monthly_content_goals", monthString].joined(separator: "/")
        let monthRef = db.document(monthPath)
        
        // set data
        monthRef.setData([
            "start_date": Timestamp(date: startOfMonth.date),
            "end_date": Timestamp(date: endOfMonth.date),
            "goal": goal
            ], merge: false)
    }
    
    class func getContentGoal() {
        // this month
        let startOfMonth = naiveDate().dateAtStartOf(.month)
        let monthString = convertToDateString(startOfMonth)
        
        // get location in FS
        let db = Firestore.firestore()
        let monthPath = ["users", String(store.state.userId!), "monthly_content_goals", monthString].joined(separator: "/")
        let monthRef = db.document(monthPath)
        
        // get data
        monthRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let goal = document.data()!["goal"] as! String
                store.dispatch(UpdateMonthlyContentGoal(goal: goal))
            } else {
                print("Month Content Goal does not exist.")
            }
            
        }
    }
}
