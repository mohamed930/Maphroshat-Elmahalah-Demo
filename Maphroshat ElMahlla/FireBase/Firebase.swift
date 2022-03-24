//
//  Firebase.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/28/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import Foundation
import Firebase
import RappleProgressHUD
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD

class FireBase {
    
    // MARK:- TODO:- This Method for Write data to dicrect child
    // ---------------------------------------------------------
    public static func write(childName:String,childID:String,value:[String:Any]) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
            .child(childName).child(childID)
        .setValue(value){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("CreateUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("CreateSuccessfully".localized)
            }
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Write data to child inside child
    // ---------------------------------------------------------
    public static func writeInsideChild(childName:String,childID:String,productchild:String,value:[String:String])
    {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
            .child(childName).child(childID).child(productchild)
        .setValue(value){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
              ProgressHUD.showError("CreateUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("CreateSuccessfully".localized)
            }
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Write data to child inside child
    // ---------------------------------------------------------
    public static func writeInsideChild2(childName:String,childID:String,productchild:String,TravelId:String,value:[String:String])
    {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
            .child(childName).child(childID).child(productchild).child("Products").child(TravelId)
        .setValue(value){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
              ProgressHUD.showError("CreateUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("CreateSuccessfully".localized)
            }
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Read data to direct child
    // ---------------------------------------------------------
    public static func readwithoutcondtion(childName:String, complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
     
        Database.database().reference().child(childName).observe(.childAdded, with: { (snap) in
            complention(snap)
        }) { (error) in
            RappleActivityIndicatorView.stopAnimation()
            ProgressHUD.showError("ReadFailed".localized)
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Read data to inside child
    // ---------------------------------------------------------
    public static func readwithoutcondtioninsidechild(childName:String,childId:String,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
     
        Database.database().reference().child(childName).child(childId).observe(.childAdded, with: { (snap) in
            complention(snap)
        }) { (error) in
            RappleActivityIndicatorView.stopAnimation()
            ProgressHUD.showError("ReadFailed".localized)
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Read data to direct child with condtion
    // ---------------------------------------------------------------------
    public static func readwithcondtion(childName:String,k:String,v:String,condition:Int, complention: @escaping (DataSnapshot) -> ()) {
        
        if condition == 1 {
            RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
            
            Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.childAdded) { (snap) in
                complention(snap)
            }
        }
        else {
            Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.childAdded) { (snap) in
                complention(snap)
            }
        }
    }
    // ---------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for Read data to inside child Cart Table
    // ------------------------------------------------------------------
    public static func readinsideCart(childUser:String,childType:String,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child("Cart List").child(childType).child(childUser).child("Products").observe(.childAdded, with: { (snap) in
            complention(snap)
        }) { (error) in
            RappleActivityIndicatorView.stopAnimation()
            ProgressHUD.showError("ReadFailed".localized)
        }
    }
    // ---------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkisEmptyCart(childName:String, Label:UILabel , Collection:UITableView ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child("Cart List").child("User View").child(childName).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                Label.isHidden = true
                Collection.isHidden = false
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                Label.text = "NoProduct".localized
                Label.isHidden = false
                Collection.isHidden = true
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    // ------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is Empty Order or not.
    // ------------------------------------------------------------------
    public static func checkisEmptyOrder(childName:String,complention: @escaping (String) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child("Cart List").child("Admin View").child(childName).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                RappleActivityIndicatorView.stopAnimation()
                complention("Success")
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                complention("Falied")
                
            }
        }
    }
    // ------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkisEmpty(childName:String,k:String,v:String, Label:UILabel , Collection:UICollectionView ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                Label.isHidden = true
                Collection.isHidden = false
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                Label.text = "NoProduct".localized
                Label.isHidden = false
                Collection.isHidden = true
            }
        }
    }
    // ------------------------------------------------------------------
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkisEmpty(childName:String,k:String,v:String, Label:UILabel , Collection:UITableView ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                Label.isHidden = true
                Collection.isHidden = false
                Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.childAdded) { (snapshot) in
                    complention(snapshot)
                }
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                Label.text = "NoProduct".localized
                Label.isHidden = false
                Collection.isHidden = true
            }
        }
    }
    // ------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkisEmpty1(childName:String,childId:String,Label:UILabel , Collection:UICollectionView ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).child(childId).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                Label.isHidden = true
                Collection.isHidden = false
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                Label.text = "NoProduct".localized
                Label.isHidden = false
                Collection.isHidden = true
            }
        }
    }
    // ------------------------------------------------------------------
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkisEmptyTableView (childName:String,Label:UILabel , Collection:UITableView ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                Label.isHidden = true
                Collection.isHidden = false
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                Label.text = "NoProduct".localized
                Label.isHidden = false
                Collection.isHidden = true
            }
        }
    }
    // ------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is Empty or not.
    // ------------------------------------------------------------------
    public static func checkNumber(childName:String,k:String,v:String,Text:UITextField, complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("Account".localized)
                Text.text = ""
            }
        }
    }
    // ------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is product added to Cart.
    // -----------------------------------------------------------------------------------
    public static func checkisAdded(childName:String,childId:String,childKey:String,TravelId:String ,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).child(childId).child(childKey)
            .child("Products").child(TravelId).observeSingleEvent(of: .value, with: { (snap) in
                if snap.childrenCount > 0 {
                    RappleActivityIndicatorView.stopAnimation()
                    ProgressHUD.showError("AddedProduct".localized)
                }
                else {
                    complention(snap)
                }
            }) { (error) in
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("Error".localized)
        }
    }
    // -----------------------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for check with condtion is product added to Fav. or Cart.
    // -----------------------------------------------------------------------------------
    public static func checkisAdded1(childName:String,childId:String,k:String,v:String,complention: @escaping (DataSnapshot) -> ()) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).child(childId).queryOrdered(byChild: k).queryEqual(toValue: v).observe(.value) { (snap) in
            if snap.childrenCount > 0 {
                complention(snap)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    // -----------------------------------------------------------------------------------
    
    
    // MARK:- TODO:- This Method For Copy Data and Past it.
    // ----------------------------------------------------
    public static func InsetFullyOrder (pautochild:String,childName:String,value:[String:String],complention: @escaping (String) -> ()) {
        
        /*
            First:- Write Data to Orders.
            Second:- Copy Data from UserView to AdminView.
            Third:- Delete Data From UserView Cart
         */
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference().child(childName).child(pautochild).setValue(value) { (error, ref) in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("CreateUnSuccessfully".localized)
            }
            else {
                
                // Copy Data From User View and Past to Admin View.
                Database.database().reference().child("Cart List").child("User View").child(pautochild).observe(.childAdded) { (snapshot) in
                    
                    Database.database().reference().child("Cart List").child("Admin View").child(pautochild).child("Products").setValue(snapshot.value) { (error, ref) in
                        if error != nil {
                              RappleActivityIndicatorView.stopAnimation()
                              ProgressHUD.showError("CreateUnSuccessfully".localized)
                              complention("Failed")
                        }
                        else {
                            RappleActivityIndicatorView.stopAnimation()
                            complention("Sucess")
                        }
                    }
                }
                // ------------------------------------------------
            }
        }
    }
    // ----------------------------------------------------
    
    
    public static func deleteCart () {
        Database.database().reference().child("Cart List").child("User View").child(UserTelephone).child("Products").removeValue()
    }
    
    
    // MARK:- TODO:- This Method for update data.
    // ------------------------------------------
    public static func update(childName:String,ChildId:String,value:[String:Any]) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
        .child(childName).child(ChildId).updateChildValues(value){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("UpdateUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("UpdateSuccessfully".localized)
            }
        }
    }
    // ------------------------------------------
    
    // MARK:- TODO:- This Method for update data.
    // ------------------------------------------
    public static func updateInsideChild(childName:String,childType:String,ChildId:String,value:[String:Any]) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
            .child(childName).child(childType).child(ChildId).updateChildValues(value){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
              ProgressHUD.showError("UpdateUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("UpdateSuccessfully".localized)
            }
        }
    }
    // ------------------------------------------
    
    
    // MARK:- TODO:- This Method for delete data.
    // ------------------------------------------
    public static func delete(childName:String,ChildId:String) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
        .child(childName).child(ChildId).removeValue(){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
              ProgressHUD.showError("DeleteUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("DeleteSuccessfully".localized)
            }
        }
    }
    // ------------------------------------------
    
    
    // MARK:- TODO:- This Method for delete data inside Child.
    // -------------------------------------------------------
    public static func deleteinsidechild(childName:String,ChildId:String,childProduct:String) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
        Database.database().reference()
            .child(childName).child(ChildId).child(childProduct).removeValue(){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
              RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("DeleteUnSuccessfully".localized)
            }
            else {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showSuccess("DeleteSuccessfully".localized)
            }
        }
    }
    // -------------------------------------------------------
    
    
    // MARK:- TODO:- This Method for delete data inside Cart.
    // -------------------------------------------------------
    public static func deleteinsideCart(ChildId:String,childProduct:String) {
        
        Database.database().reference().child("Cart List").child("User View").child(ChildId).child("Products").child(childProduct).removeValue()
        
    }
    // -------------------------------------------------------
    
    // MARK:- TODO:- This Method for delete data inside Cart.
    // -------------------------------------------------------
    public static func deleteinsideCartAdmin(ChildId:String) {
        
        Database.database().reference().child("Cart List").child("Admin View").child(ChildId).removeValue()
        
    }
    // -------------------------------------------------------
    
    public static func deleteImage (ImageURL:String,complination: @escaping (String)-> ()) {
        let storage = Storage.storage().reference(forURL: ImageURL)
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        storage.delete { (error) in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
                ProgressHUD.showError("Error".localized)
            }
            else {
                complination("Sucess")
            }
        }
    }
    
    // MARK:- TODO:- This Method for Upload Image.
    // --------------------------------------------
    public static func uploadMedia(urlReference:String,ImageName:String,PickedImage:UIImage,completion: @escaping (_ url: String?) -> Void) {
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
        
       let StorageRef = Storage.storage().reference(forURL: urlReference)
       let starsRef = StorageRef.child(ImageName)
        if let uploadData = PickedImage.pngData() {
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            starsRef.putData(uploadData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {
                    starsRef.downloadURL { (url, error) in
                        if error != nil {
                            print("error")
                        }
                        else {
                            completion(url?.absoluteString)
                        }
                    }
                }
            }
        }
        
    }
    // --------------------------------------------
    
    
    // MARK:- TODO:- This Method For Downlaod Image.
    public static func DownloadImage (ReferenceURL:String,ImageURL:String,ImageView:UIImageView) {

        let StorageRef = Storage.storage().reference(forURL: ReferenceURL)
        let islandRef = StorageRef.child(ImageURL)

        islandRef.getData(maxSize: 8*1024*768) { (data, error) in
            if let error = error {
                print(error)
            } else {
                // print Image From Data.
                ImageView.image = UIImage(data: data!)
            }
        }
    }
    // --------------------------------------------
}
