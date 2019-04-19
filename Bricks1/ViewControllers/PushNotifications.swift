import Firebase

extension AppDelegate: MessagingDelegate {
    // FIREBASE MESSAGING
    // full reference : https://github.com/firebase/quickstart-ios/blob/e41348b60467d809c719b83173c826420d826ab2/messaging/MessagingExampleSwift/AppDelegate.swift
    
    /// This callback is fired at each Firebase app startup and whenever a new token is generated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // If the registration token is new, send it to your application server.
        // Subscribe the registration token to topics. This is required only for new subscriptions or for situations where the user has re-installed the app.
        // https://firebase.google.com/docs/cloud-messaging/ios/client?authuser=0#fetching-the-current-registration-token
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                store.dispatch(SaveFIRPushNotifToken(firPushNotifToken : result.token))
//                Fetch.putAppUser(["": result.token])
            }
        }
    }
    
    // TODO this method never gets called. why not?
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        print("FIRST VERSION OF METHOD")
    }
    
    // TODO this method never gets called. why not?
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        print("SECOND VERSION OF METHOD")

        
        completionHandler(UIBackgroundFetchResult.newData)
    }

}
