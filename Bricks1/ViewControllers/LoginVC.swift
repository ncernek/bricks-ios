import UIKit
import GoogleSignIn

// instructions to add Google Sign in
// https://developers.google.com/identity/sign-in/ios/start-integrating
class LoginVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // automatically sign in the user.
        // https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift
        GIDSignIn.sharedInstance().signInSilently()
        
    }
    
    @IBAction func triggerDemoLogin(_ sender: Any) {
        let config = AppConfig()
//        store.dispatch(ActionSaveAuthTokenAndUID(authToken: config.DEMO_ACCOUNT_GOOGLE_ID, userId: 46))
        store.dispatch(ActionSaveUsername(username: "Joseph Smith"))
        store.dispatch(ActionSaveGoogleToken(googleToken: config.DEMO_ACCOUNT_GOOGLE_ID))
        Fetch.login(config.DEMO_ACCOUNT_GOOGLE_ID)
//        Fetch.refreshData()
    }
    
}
