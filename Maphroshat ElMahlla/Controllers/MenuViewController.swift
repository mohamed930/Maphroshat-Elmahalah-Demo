//
//  MenuViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/30/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD

class MenuViewController: UIViewController {
    
    var menuview: MenuView! {
        guard isViewLoaded else { return nil }
        return (view as! MenuView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Tools.makecornerCircle(View: menuview.ProfileImage, borderColor: "#FFFFFF")
        MakeTouchAction()
        ReadProfileData()
        
        if "lang".localized == "en" {
            LabelDirection(labelName: self.menuview.Label1, Alighment: .left)
            LabelDirection(labelName: self.menuview.Label2, Alighment: .left)
            LabelDirection(labelName: self.menuview.Label3, Alighment: .left)
            LabelDirection(labelName: self.menuview.Label4, Alighment: .left)
            LabelDirection(labelName: self.menuview.Label5, Alighment: .left)
        }
        else {
            LabelDirection(labelName: self.menuview.Label1, Alighment: .right)
            LabelDirection(labelName: self.menuview.Label2, Alighment: .right)
            LabelDirection(labelName: self.menuview.Label3, Alighment: .right)
            LabelDirection(labelName: self.menuview.Label4, Alighment: .right)
            LabelDirection(labelName: self.menuview.Label5, Alighment: .right)
        }
    }
    
    func LabelDirection (labelName: UILabel , Alighment: NSTextAlignment) {
         labelName.textAlignment = Alighment
    }
    
    func MakeTouchAction () {
        var tab = UITapGestureRecognizer()
        tab = UITapGestureRecognizer(target: self, action: #selector(Logout(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        menuview.Line4.isUserInteractionEnabled = true
        menuview.Line4.addGestureRecognizer(tab)
        
        
        tab = UITapGestureRecognizer(target: self, action: #selector(Setting(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        menuview.Line5.isUserInteractionEnabled = true
        menuview.Line5.addGestureRecognizer(tab)
        
        tab = UITapGestureRecognizer(target: self, action: #selector(Cart(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        menuview.Line1.isUserInteractionEnabled = true
        menuview.Line1.addGestureRecognizer(tab)
        
        tab = UITapGestureRecognizer(target: self, action: #selector(Fav(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        menuview.Line3.isUserInteractionEnabled = true
        menuview.Line3.addGestureRecognizer(tab)
        
    }
    
    func ReadProfileData() {
        FireBase.readwithcondtion(childName: "Users", k: "phone", v: UserTelephone,condition: 2) { (snapshot) in
            let value = snapshot.value as! Dictionary<String,String>
            self.menuview.UserName.text = value["name"]!
            ProfileViewController.Address = value["address"]!
            
            if value["image"]! == "null" {
                self.menuview.ProfileImage.image = UIImage(named: "profile")
            }
            else {
                ProfileViewController.imageUrl = value["image"]!
                Tools.getPhoto(URL: value["image"]!, Image: self.menuview.ProfileImage)
            }
        }
    }
    
    @objc func Logout(tapGestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Attention".localized , message: "Exit".localized , preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Cancel".localized , style: .cancel, handler: nil)
        alert.addAction(action1)
        
        let action2 = UIAlertAction(title: "logout".localized , style: .default) { (alert) in
            LoginViewController.flag = 1
            let appDel = UIApplication.shared.delegate as! AppDelegate
            let story = UIStoryboard(name: "Main", bundle: nil)
            let next = story.instantiateViewController(withIdentifier: "login") as! LoginViewController
            appDel.window?.rootViewController = next
            appDel.window?.makeKeyAndVisible()
        }
        alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    // ----------------------------------------------------------------
    
    @objc func Setting(tapGestureRecognizer: UITapGestureRecognizer) {
        ProfileViewController.Name = self.menuview.UserName.text!
        Tools.openForm(MainViewName: "Main", FormID: "ProfileView", ob: self)
    }
    // ----------------------------------------------------------------
    
    @objc func Cart(tapGestureRecognizer: UITapGestureRecognizer) {
        FireBase.checkisEmptyOrder(childName: UserTelephone) { (result) in
            if result == "Success" {
                RappleActivityIndicatorView.stopAnimation()
                Tools.openForm(MainViewName: "Main", FormID: "ShipedView", ob: self)
            }
            else if result == "Falied" {
                Tools.openForm(MainViewName: "Main", FormID: "CartView", ob: self)
            }
        }
     }
    // ----------------------------------------------------------------
    
    @objc func Fav(tapGestureRecognizer: UITapGestureRecognizer) {
         Tools.openForm(MainViewName: "Main", FormID: "FavView", ob: self)
     }
    // ----------------------------------------------------------------
}
