//
//  ProfileViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 9/3/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    var PickedImage:UIImage!
    
    var profileview: ProfileView! {
        guard isViewLoaded else { return nil }
        return (view as! ProfileView)
    }
    
    static var Name:String?
    static var imageUrl = "null"
    static var Address:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
        
        Tools.makecornerCircle(View: profileview.ProfileImage , borderColor: "#FFFFFF")
        profileview.NameTextField.text = ProfileViewController.Name!
        profileview.TelephoneTextField.text = UserTelephone
        profileview.AddressTextField.text = ProfileViewController.Address!
        
        if ProfileViewController.imageUrl == "null" {
            profileview.ProfileImage.image = UIImage(named: "profile")
        }
        else {
            Tools.getPhoto(URL: ProfileViewController.imageUrl, Image: profileview.ProfileImage)
        }
        
    }
    
    @IBAction func BTNClose (_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BTNPickImage(_ sender:Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image,animated: false)
        {
            
        }
    }
    
    @IBAction func BTNUpdate(_ sender:Any) {
        
        var data: [String:Any]
        
        if PickedImage == nil {
            
            data = [
                        "name": profileview.NameTextField.text!,
                        "address": profileview.AddressTextField.text!,
                        "phoneOrder:":"null"
                   ]
            FireBase.update(childName: "Users", ChildId: UserTelephone, value: data)
            
        }
        else {
            
            FireBase.uploadMedia(urlReference: "gs://elmahala-app.appspot.com/Profile pictures", ImageName: "\(UserTelephone)@g.com", PickedImage: PickedImage) { (url) in
                let data = [
                                "name": self.profileview.NameTextField.text!,
                                "address": self.profileview.AddressTextField.text!,
                                "image": url!,
                                "phoneOrder:":"null"
                            ] as [String : Any]
                    FireBase.update(childName: "Users", ChildId: UserTelephone, value: data)
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

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case profileview.TelephoneTextField:
                profileview.NameTextField.becomeFirstResponder()
            break
            case profileview.NameTextField:
                profileview.AddressTextField.becomeFirstResponder()
            break
            default:
                self.view.endEditing(true)
            break
        }
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            PickedImage = image
            profileview.ProfileImage.image = image
        }
        else
        {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}
