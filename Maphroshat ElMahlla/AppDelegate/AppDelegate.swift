//
//  AppDelegate.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import KYDrawerController
import IQKeyboardManagerSwift
import MOLH

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , MOLHResetable {

    var window: UIWindow?
    
    var drawerController = KYDrawerController.init(drawerDirection: .left, drawerWidth: 300)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        //MOLHLanguage.setDefaultLanguage("en")
        MOLH.shared.activate(true)
        FirebaseApp.configure()
        return true
    }
    
    func reset() {
          let stry = UIStoryboard(name: "Main", bundle: nil)
          window?.rootViewController = stry.instantiateInitialViewController()
     }
}

extension String {
    var localized:String {
        return NSLocalizedString(self, comment: "")
    }
}
