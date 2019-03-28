import UIKit
import Firebase
import FirebaseUI


/// show appropriate VC depending on login status
func setVCforLogin(loggedIn: Bool = false) {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let authUI = FUIAuth.defaultAuthUI()
    var rootVC : UIViewController?
    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
    
    
    if let currentUser = Auth.auth().currentUser { // FIR caches user from previous session
        
        // save FIR user to state
        
        if loggedIn {
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
        } else {
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loadingVC") as! UIViewController
            loginToBackend(currentUser)
        }
    } else {
        rootVC = authUI?.authViewController()
    }
    
    appDelegate.window?.rootViewController = rootVC
    appDelegate.window?.makeKeyAndVisible()

}




func loginToBackend(_ currentUser: User) {
    store.dispatch(SaveUserDetails(currentUser: currentUser))
    
    if let photoURL = currentUser.photoURL {
        Fetch.getImage(photoURL)
    }
    
    currentUser.getIDTokenForcingRefresh(true) { idToken, error in
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            // pass token to backend
            print("TOKEN: ", idToken!)
            store.dispatch(ActionSaveGoogleToken(googleToken: idToken!))
            Fetch.login(store.state.googleToken!)
        }
    }
}
