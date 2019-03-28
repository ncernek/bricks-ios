import Foundation
import UIKit
import FirebaseUI


class SettingsVC: UIViewController {
    
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
    
    
}
