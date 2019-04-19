import Foundation
import UIKit
import FirebaseUI


class SettingsVC: UIViewController {
    
    @IBOutlet var taskNotifSwitch: UISwitch!
    @IBOutlet var messageNotifSwitch: UISwitch!
    @IBOutlet var appVersion: UILabel!
    
    override func viewDidLoad() {
        taskNotifSwitch.isOn = store.state.appUser!.taskNotifs
        messageNotifSwitch.isOn = store.state.appUser!.chatNotifs
        appVersion.text = "Version \(AppConfig().APP_VERSION)"
    }
    
    @IBAction func triggerJoinTeam(_ sender: Any) {
        Alerts.joinTeam(self)
    }
    
    @IBAction func triggerCreateTeam(_ sender: Any) {
        Alerts.createTeam(self)
    }
    
    
    @IBAction func triggerSignOut(_ sender: AnyObject) {
        let authUI = FUIAuth.defaultAuthUI()!
        try? authUI.signOut()
        setVCforLogin(loggedIn: false)
        store.dispatch(ActionLogOut())
    }
    
    @IBAction func toggleTaskNotif(_ sender: UISwitch) {
        Fetch.putAppUser([
            "task_notifs": sender.isOn
        ])
    }
    
    @IBAction func toggleMessageNotif(_ sender: UISwitch) {
        Fetch.putAppUser([
            "chat_notifs": sender.isOn
            ])
    }
    
    
    
}
