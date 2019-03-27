import UIKit

/// switch VC from Login VC to Landing VC
func switchViewControllers(loggedIn: Bool) {
    var rootVC : UIViewController?
    
    if(loggedIn == true) {
        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navigationvc") as! UINavigationController
    } else {
        rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginVC
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    DispatchQueue.main.async {
        appDelegate.window?.rootViewController = rootVC
    }
}
