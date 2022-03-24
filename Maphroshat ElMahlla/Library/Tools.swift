//
//  Tools.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import Alamofire
import AlamofireImage
import MOLH

var UserTelephone = ""
var AdminStatus1: String = "Not Admin"

class Tools {
    
    public static func openForm (MainViewName:String,FormID:String,ob:UIViewController) {
        let storyBoard = UIStoryboard(name: MainViewName, bundle: nil)
        let next = storyBoard.instantiateViewController(withIdentifier: FormID)
        next.modalPresentationStyle = .fullScreen
        ob.present(next, animated: true, completion: nil)
    }
    
    public static func openFormWithroot (MainViewName:String,FormID:String,ob:UIViewController) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let story = UIStoryboard(name: MainViewName, bundle: nil)
        let next = story.instantiateViewController(withIdentifier: FormID)
        appDel.window?.rootViewController = next
        appDel.window?.makeKeyAndVisible()
    }
    
    public static func setLeftPadding(textField:UITextField,paddingValue:Int,PlaceHolder:String , Color:UIColor) {
        
        if "lang".localized == "en" || MOLHLanguage.currentAppleLanguage() == "en" {
            textField.textAlignment = .left
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: 20))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }
        else if "lang".localized == "ar" || MOLHLanguage.currentAppleLanguage() == "ar" {
            textField.textAlignment = .right
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: 20))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        }
        
        textField.attributedPlaceholder = NSAttributedString(string: PlaceHolder,
        attributes: [NSAttributedString.Key.foregroundColor: Color])
    }
    
    public static func SetImage(textfield: UITextField,paddingValue:Int,PlaceHolder:String , Color:UIColor) {
        textfield.layer.borderWidth = 4.0
        textfield.layer.borderColor = UIColor().hexStringToUIColor(hex: "#FF9D00").cgColor
        textfield.layer.cornerRadius = 15.0
        textfield.layer.masksToBounds = true
        
        if "lang".localized == "en" || MOLHLanguage.currentAppleLanguage() == "en" {
            textfield.textAlignment = .left
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: 20))
            textfield.leftView = paddingView
            textfield.leftViewMode = .always
        }
        else if "lang".localized == "ar" || MOLHLanguage.currentAppleLanguage() == "ar" {
            textfield.textAlignment = .right
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: 20))
            textfield.leftView = paddingView
            textfield.leftViewMode = .always
        }
        
        textfield.attributedPlaceholder = NSAttributedString(string: PlaceHolder,
        attributes: [NSAttributedString.Key.foregroundColor: Color])
    }
    
    public static func createAlert (Title:String , Mess:String , ob:UIViewController)
    {
        let alert = UIAlertController(title: Title , message:Mess
            , preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title:"OK".localized,style:UIAlertAction.Style.default,handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        ob.present(alert,animated:true,completion: nil)
    }
    
    public static func MakeLineThrough(Title:String,Label:UILabel) {
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: Title)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: NSMakeRange(0, attributeString.length))
        
        Label.attributedText = attributeString
    }
    
    public static func makecornerCircle (View:UIImageView , borderColor:String) {
        View.layer.cornerRadius = View.frame.size.width/2
        View.clipsToBounds = true

        View.layer.borderColor = UIColor().hexStringToUIColor(hex: borderColor).cgColor
        View.layer.borderWidth = 2.5
    }
    
    public static func MakeRound(myView:AnyObject,v:CACornerMask) {
        //myView.clipsToBounds = true
        if #available(iOS 13.0, *) {
            myView.layer.cornerRadius = 15.0
        } else {
            // Fallback on earlier versions
        }
        
        /*
            top-right:    layerMaxXMinYCorner
            top-left:     layerMinXMinYCorner
            button-right: layerMaxXMaxYCorner
            button-left:  layerMinXMaxYCorner
         */
        if #available(iOS 13.0, *) {
            myView.layer.maskedCorners = v
        } else {
            // Fallback on earlier versions
        }
    }
    
    public static func getPhoto (URL:String,Image:UIImageView) {
           AF.request(URL).responseImage(completionHandler: {
               (response) in
               if let image1 = response.value {
                   let size = CGSize(width: 1000.0, height: 1000.0)
                   let scaleImage = image1.af.imageScaled(to: size)
                   DispatchQueue.main.async {
                       Image.image = scaleImage
                   }
                   RappleActivityIndicatorView.stopAnimation()
               }
           })
       }
    
    public static func SetButtonImage (ButtonName: UIButton,ImageName: String) {
        ButtonName.setBackgroundImage(UIImage(named: ImageName), for: .normal)
        //ButtonName.setImage(UIImage(named: ImageName), for: .normal)
    }
}
