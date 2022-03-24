//
//  SignupViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import FirebaseDatabase
import ProgressHUD

class SignupViewController: UIViewController {
    
    let padding = 15
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var signupview: SignupView! {
        guard isViewLoaded else { return nil}
        return (view as! SignupView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK:- TODO:- This Line for adding Geusters.
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
        
        /*Tools.setLeftPadding(textField: signupview.NameText, paddingValue: padding, PlaceHolder: "Name", Color: UIColor.orange)
        Tools.setLeftPadding(textField: signupview.PhoneNumberText, paddingValue: padding, PlaceHolder: "Phone Number", Color: UIColor.orange)
        Tools.setLeftPadding(textField: signupview.PasswordText, paddingValue: padding, PlaceHolder: "Password", Color: UIColor.orange)*/
        
        Tools.SetImage(textfield: signupview.NameText, paddingValue: padding, PlaceHolder: "Name".localized, Color: UIColor.orange)
        Tools.SetImage(textfield: signupview.PhoneNumberText, paddingValue: padding, PlaceHolder: "PhoneNumber".localized, Color: UIColor.orange)
        Tools.SetImage(textfield: signupview.PasswordText, paddingValue: padding, PlaceHolder: "Password".localized, Color: UIColor.orange)
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: signupview.BTNSignup , ImageName: "BTNCeateAccountAR")
        }
    }
    
    @IBAction func BTNCreateAccount(_ sender:Any) {
        CreateAccount()
    }
    
    func CreateAccount() {
        
        if signupview.NameText.text! == "" || signupview.PasswordText.text! == "" || signupview.PhoneNumberText.text! == "" {
            Tools.createAlert(Title: "Error1".localized, Mess: "Mess".localized, ob: self)
        }
        else {
            
            RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
            
            Database.database().reference().child("Users").queryOrdered(byChild: "phone").queryEqual(toValue: signupview.PhoneNumberText.text!).observe(.value) { (snap) in
                if snap.childrenCount > 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    ProgressHUD.showError("AccountExsist".localized)
                    self.signupview.PhoneNumberText.text = ""
                }
                    
                else {
                    let values = [
                                    "name":self.signupview.NameText.text!,
                                    "password":self.signupview.PasswordText.text!,
                                    "phone":self.signupview.PhoneNumberText.text!,
                                    "address":"null",
                                    "image":"null",
                                    "phoneOrder:":"null"
                                 ]
                    
                    FireBase.write(childName: "Users", childID: self.signupview.PhoneNumberText.text!, value: values)
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

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == signupview.PhoneNumberText {
            if signupview.PhoneNumberText.text!.count < 11 || signupview.PhoneNumberText.text!.count > 11 {
                Tools.createAlert(Title: "Error1".localized , Mess: "MessTele".localized, ob: self)
                signupview.PhoneNumberText.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case signupview.NameText:
                signupview.PhoneNumberText.becomeFirstResponder()
            break
            case signupview.PhoneNumberText:
                signupview.PasswordText.becomeFirstResponder()
            break
        default:
            // Make Signup opeation
            self.view.endEditing(true)
            CreateAccount()
        }
        return true
    }
}
