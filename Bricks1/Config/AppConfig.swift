import Foundation

class AppConfig {
    private let config: NSDictionary
    
    init() {
        let bundle = Bundle.main
        let configPath = bundle.path(forResource: "Info", ofType: "plist")!
        config = NSDictionary(contentsOfFile: configPath)!
    }

    var CONFIG_NAME : String {
        return config["CONFIG_NAME"] as! String
    }
    
    // BRICKS SERVER API
    var DOMAIN_BRICKS_SERVER : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"] as! String)!
    }
    var URL_AUTH_TOKEN : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_AUTH_TOKEN"] as! String))!
    }
    var URL_TASK : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_TASK"] as! String))!
    }
    var URL_APP_USER : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_APP_USER"] as! String))!
    }
    var URL_TEAM : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_TEAM"] as! String))!
    }
    var URL_INVITE : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_INVITE"] as! String))!
    }
    var URL_JOIN : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_JOIN"] as! String))!
    }
    var URL_FEEDBACK : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_FEEDBACK"] as! String))!
    }
    var URL_STATS : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_STATS"] as! String))!
    }
    var URL_NUDGE : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_NUDGE"] as! String))!
    }
    var URL_ASSIST : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_ASSIST"] as! String))!
    }
    var URL_CHAT : URL {
        return URL(string: config["DOMAIN_BRICKS_SERVER"]  as! String + (config["PATH_CHAT"] as! String))!
    }
    
    // GOOGLE SIGN IN
    var REVERSED_CLIENT_ID : String {
        return config["REVERSED_CLIENT_ID"] as! String
    }
    var CLIENT_ID : String {
        return config["CLIENT_ID"] as! String
    }
    var BUNDLE_ID : String {
        return config["BUNDLE_ID"] as! String
    }
    
    // DEMO
    var DEMO_ACCOUNT_GOOGLE_ID : String {
        return config["DEMO_ACCOUNT_GOOGLE_ID"] as! String
    }
    
    // APP VERSION
    var APP_VERSION : String {
        return config["CFBundleShortVersionString"] as! String
    }
}
