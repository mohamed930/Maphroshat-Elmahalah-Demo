//
//  ViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import ProgressHUD

class wlcomeViewController: UIViewController {
    
    @IBOutlet weak var ButtonSignup: UIButton!
    @IBOutlet weak var ButtonSignin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: ButtonSignup, ImageName: "BTNSignupAR")
            Tools.SetButtonImage(ButtonName: ButtonSignin, ImageName: "BTNLoginAr-1")
        }
    }
    
    func setLogin() {
        guard let Action = UserDefaults.standard.object(forKey: "Action") else {
            Tools.openForm(MainViewName: "Main", FormID: "login", ob: self)
            return
        }
        
        if Action as! String == "2" {
            RappleActivityIndicatorView.startAnimatingWithLabel("Wait".localized, attributes: RappleModernAttributes)
            
            UserTelephone = UserDefaults.standard.object(forKey: "Phone") as! String
            
            RappleActivityIndicatorView.stopAnimation()
            
            let appDel = UIApplication.shared.delegate as! AppDelegate
            
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "SideMenu")
            
            appDel.drawerController.mainViewController = mainVC
            appDel.drawerController.drawerViewController = menuVC
            
            appDel.window?.rootViewController = appDel.drawerController
            appDel.window?.makeKeyAndVisible()
            
            //Tools.openForm(MainViewName: "Main", FormID: "Home", ob: self)
            
        }
        else {
            Tools.openForm(MainViewName: "Main", FormID: "login", ob: self)
        }
    }
    
    @IBAction func BTNJoinNow (_ sender:Any) {
        Tools.openForm(MainViewName: "Main", FormID: "Signup", ob: self)
    }
    
    @IBAction func BTNLogin (_ sender:Any) {
        setLogin()
    }
}

