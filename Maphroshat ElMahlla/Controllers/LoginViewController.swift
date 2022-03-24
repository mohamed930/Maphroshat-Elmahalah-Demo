//
//  LoginViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import ProgressHUD

class LoginViewController: UIViewController {
    
    var SavedType = 0
    let padding = 15
    var screenedge : UIScreenEdgePanGestureRecognizer!
    static var flag = 0
    
    var Adminstatus = false
    
    var loginview: LoginView! {
        guard isViewLoaded else { return nil }
        return (view as! LoginView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK:- TODO:- This Line for adding Geusters.
        if LoginViewController.flag == 0 {
            screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
            screenedge.edges = .left
            view.addGestureRecognizer(screenedge)
        }
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: loginview.BTNLogin , ImageName: "BTNLoginAR")
        }
        
        /*Tools.setLeftPadding(textField: loginview.PhoneText, paddingValue: padding, PlaceHolder: "Phone number", Color: UIColor.orange)
        Tools.setLeftPadding(textField: loginview.PasswordText, paddingValue: padding, PlaceHolder: "Password", Color: UIColor.orange)*/
        
        Tools.SetImage(textfield: loginview.PhoneText, paddingValue: padding, PlaceHolder: "PhoneNumber".localized , Color: UIColor.orange)
        Tools.SetImage(textfield: loginview.PasswordText, paddingValue: padding, PlaceHolder: "Password".localized , Color: UIColor.orange)
    }
    
    @IBAction func BTNSaveMe(_ sender:UIButton) {
        if sender.isSelected{
            print("dis Selected")
            SavedType = 0
            sender.isSelected = false
        }
        else {
            print("Selected")
            SavedType = 1
            sender.isSelected = true
        }
    }
    
    @IBAction func BTNAdmin (_ sender:UIButton) {
        if sender.isSelected{
            print("dis Selected")
            Adminstatus = false
            sender.isSelected = false
            loginview.BTNAdmin.setTitle("AdminMess".localized , for: .normal)
        }
        else {
            print("Selected")
            Adminstatus = true
            sender.isSelected = true
            loginview.BTNAdmin.setTitle("UserMess".localized , for: .normal)
        }
    }
    
    @IBAction func BTNlogin(_ sender:Any) {
        if Adminstatus == false {
            MakeLogin()
        }
        else {
            MakeAdminLogin()
        }
    }
    
    func MakeLogin() {
        
        if loginview.PhoneText.text == "" || loginview.PasswordText.text == "" {
            Tools.createAlert(Title: "Error1".localized , Mess: "Mess".localized , ob: self)
        }
        else {

            FireBase.checkNumber(childName: "Users", k: "phone", v: loginview.PhoneText.text!,Text: loginview.PasswordText) { (snap) in
                
                FireBase.readwithcondtion(childName: "Users", k: "phone", v: self.loginview.PhoneText.text!,condition: 1) { (snap) in
                    
                    let value = snap.value as! Dictionary<String,String>
                    
                    if self.loginview.PasswordText.text! == value["password"]! {
                        
                        if self.SavedType == 1 {
                            UserDefaults.standard.set(self.loginview.PhoneText.text, forKey: "Phone")
                            UserDefaults.standard.set(self.loginview.PasswordText.text, forKey: "Password")
                            UserDefaults.standard.set("2", forKey: "Action")
                        }
                        
                        // Open.
                        print("Sucess!")
                        UserTelephone = self.loginview.PhoneText.text!
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
                        ProgressHUD.showError("loginMess".localized)
                        self.loginview.PasswordText.text = ""
                        RappleActivityIndicatorView.stopAnimation()
                    }
                }
            }
        }
        
    }
    
    func MakeAdminLogin() {
        
        if loginview.PhoneText.text == "" || loginview.PasswordText.text == "" {
            Tools.createAlert(Title: "Error1".localized, Mess: "Mess".localized , ob: self)
        }
        else {
            FireBase.checkNumber(childName: "Admins",k: "phone", v: loginview.PhoneText.text!,Text: loginview.PasswordText) { (snap) in
                
                FireBase.readwithcondtion(childName: "Admins", k: "phone", v: self.loginview.PhoneText.text!,condition: 1) { (snap) in
                    
                     let value = snap.value as! Dictionary<String,String>
                     
                     if self.loginview.PasswordText.text! == value["password"]! {
                         // Open.
                         RappleActivityIndicatorView.stopAnimation()
                         print("Sucess!")
                         AdminStatus1 = "Admin is Here"
                         Tools.openForm(MainViewName: "Admin View", FormID: "AdminHome", ob: self)
                     }
                     else {
                        ProgressHUD.showError("loginMess".localized)
                        self.loginview.PasswordText.text = ""
                        RappleActivityIndicatorView.stopAnimation()
                    }
                }
                
            }
        }
    }
    
    // MARK:- TODO:- This Method For Add GuesterAction
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginview.PhoneText {
            loginview.PasswordText.becomeFirstResponder()
        }
        else {
            // Make Login Operation
            self.view.endEditing(true)
            if Adminstatus == false {
                MakeLogin()
            }
            else {
                MakeAdminLogin()
            }
        }
        return true
    }
}
