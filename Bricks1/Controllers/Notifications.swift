import Foundation
import UserNotifications


// local notifications implemented based on
// https://www.hackingwithswift.com/read/21/overview
class Notifications {
    static let userNotifCenter = UNUserNotificationCenter.current()

    class Notif {
        let notifId, body, category: String
        var title: String
        let isRepeating: Bool
        var hour: Int? = nil
        var timeInterval: Double = 0.1
        
        init(notifId: String, title: String, body: String, category: String,
             isRepeating: Bool, hour: Int? = nil, timeInterval: Double? = nil) {
            self.notifId = notifId
            self.title = title
            self.body = body
            self.category = category
            self.isRepeating = isRepeating
            if let specified = hour {
                self.hour = specified
            }
            if let specified = timeInterval {
                self.timeInterval = specified
            }
        }
    }

    static let notifChooseTask = Notif(
        notifId: "CHOOSE_TASK",
        title: "Choose a task",
        body: "What's your top task today?",
        category: "REMINDERS",
        isRepeating: true,
        hour: 8
    )

    static let notifGradeTask = Notif(
        notifId: "GRADE_TASK",
        title: "Grade your task",
        body: "On a scale of 0 to 5, how well did you do your task today?",
        category: "REMINDERS",
        isRepeating: true,
        hour: 21
    )

    static let notifTaskChosen = Notif(
        notifId: "TASK_CHOSEN",
        title: "+1 pt earned!",
        body: "I'll follow up with you tonight to check on your progress.",
        category: "",
        isRepeating: false,
        timeInterval: 0.1)
    
    static var notifTaskGraded = Notif(
        notifId: "TASK_GRADED",
        // TODO make this optional
        title: "+1 pt earned!",
        body: "Keep up the good work.",
        category: "",
        isRepeating: false,
        timeInterval: 0.1)

    // ACTIONS
    static let replyAction = UNTextInputNotificationAction(identifier: "REPLY", title: "Reply", options: [.foreground], textInputButtonTitle: "submit", textInputPlaceholder: "")

    // INITIALIZER FUNCTIONS
    class func setNotificationCategories() {
        let remindersCategory = UNNotificationCategory(identifier: "REMINDERS", actions: [replyAction], intentIdentifiers: [])

        userNotifCenter.setNotificationCategories([remindersCategory])
    }
    
    class func setContent(options: Notif) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = options.title
        content.body = options.body
        content.categoryIdentifier = options.category
        content.userInfo = ["notifId": options.notifId]
        content.sound = UNNotificationSound.default
        return content
    }

    class func createLocalNotification(_ notif: Notif, repeats: Bool = false) {
        let content = setContent(options: notif)
        var trigger: UNNotificationTrigger
        
        if repeats {
            trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: notif.hour), repeats: true)}
        else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: notif.timeInterval, repeats: false)}
        
        let request = UNNotificationRequest(identifier: notif.notifId, content: content, trigger: trigger)
        
        userNotifCenter.add(request) { (error) in
            if let error = error {
                print("Creating Notif failed ", error)
                return
            }
        }
    }
}
