//
//  SettingsVC.swift
//  Bricks1
//
//  Created by Nico Cernek on 2/19/19.
//  Copyright © 2019 Nico Cernek. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

class SettingsVC: UIViewController {
    
    @IBAction func triggerJoinTeam(_ sender: Any) {
        Alerts.joinTeam(self)
    }
    
    @IBAction func triggerCreateTeam(_ sender: Any) {
        Alerts.createTeam(self)
    }
    
    
    @IBAction func triggerSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        print("user signed out")
        store.dispatch(ActionLogOut())
    }
    
    
}
