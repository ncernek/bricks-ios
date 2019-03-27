import Foundation
import UserNotifications
import UIKit

// necessary to show local notifications in the app
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    
    /// handle device token from APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceToken = tokenParts.joined()
        print("Device Token from APNs: \(deviceToken)")
        Fetch.putAppUser(["device_token": deviceToken])
    }
    /// handle failed device token response
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}


extension LandingVC: UNUserNotificationCenterDelegate {
        
    func allowNotifications() {
        Notifications.userNotifCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("LANDING_VC: notification permissions: \(granted)")
            if granted == true { self.getNotificationSettings() }
            else { print(error?.localizedDescription)}
        }
    }
    
    func getNotificationSettings() {
        Notifications.userNotifCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            // TODO these may be getting regenerated every time, so you need to delete the old ones
            // not sure if these all belong here. the idea is that, if notif settings ever change
            // then these will be created. but does delegation need to happen elsewhere?
            Notifications.userNotifCenter.delegate = self
            Notifications.setNotificationCategories()
            Notifications.createLocalNotification(Notifications.notifChooseTask, repeats: true)
            Notifications.createLocalNotification(Notifications.notifGradeTask, repeats: true)

        }
    }
    
    // handle responses to notif actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionId = response.actionIdentifier
        let notifId = response.notification.request.content.userInfo["notifId"] as? String ?? "NO NOTIF ID PRESENT"
        
        switch notifId {
        case Notifications.notifChooseTask.notifId:
            switch actionId {
            case UNNotificationDefaultActionIdentifier:
                Alerts.chooseTask(self, dueDelta: 0)
            case "REPLY":
                if let textResponse = response as? UNTextInputNotificationResponse {
                    let reply = textResponse.userText
                    Task.createNewTask(reply, dueDelta: 0)
                }
            default:
                break
            }
        case Notifications.notifGradeTask.notifId:
            switch actionId {
            case UNNotificationDefaultActionIdentifier:
                Alerts.gradeTask(self)
            case "REPLY":
                if let textResponse = response as? UNTextInputNotificationResponse {
                    let reply = textResponse.userText
                    let replyInt: Int = Int(reply) ?? 0
                    Task.updateTaskGrade(replyInt)
                }
            default:
                break
            }
        default:
            break
        }
        completionHandler()
    }
    
    // For displaying banner message while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
