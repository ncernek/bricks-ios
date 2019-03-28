import UIKit
import UserNotifications
import GoogleSignIn
import ReSwift
import FirebaseUI
import Firebase

// The global application store, which is responsible for managing the appliction state.
let store = Store(
    reducer: appReducer,
    state: AppState(),
    middleware: [])


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate { // GIDSignInDelegate

    var window: UIWindow?
    let appConfig = AppConfig()
    var authViewController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // get control of notifications
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        authUI?.providers = [
            FUIGoogleAuth(),
            FUIEmailAuth()
        ]
        
        setVCforLogin()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Fetch.refreshData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // FIREBASE AUTH METHODS
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            Alerts.confirmation(authViewController!, title: "Error", message: "Error signing in. Please try again.")
            print(error.localizedDescription)
        } else if let currentUser = user {
            loginToBackend(currentUser)
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return FUICustomAuthPickerViewController(nibName: nil, //"FUICustomAuthPickerViewController",
                                                 bundle: Bundle.main,
                                                 authUI: authUI)
    }
    
    // GOOGLE SIGN-IN METHODS
    
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url as URL?,
//                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
//    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
//              withError error: Error!) {
//        if let error = error {
//            print("\(error.localizedDescription)")
//        } else {
//            // Perform any operations on signed in user here.
//            store.dispatch(ActionSaveGoogleToken(googleToken: user.authentication.idToken))
//            store.dispatch(ActionSaveUsername(username: user.profile.name))
//            let imageURL = user.profile.imageURL(withDimension: 100)
//            Fetch.login(store.state.googleToken!)
//            Fetch.getImage(imageURL!)
//        }
//    }
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//
//    }
}

