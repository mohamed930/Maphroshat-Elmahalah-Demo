//
//  ProductDetailsViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/30/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    
    static var onece:Products?
    
    static var count:Int = 1
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var productdetalisview: ProductDetailsView! {
        guard isViewLoaded else { return nil }
        return (view as! ProductDetailsView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: productdetalisview.BTNAddToCard , ImageName: "BTNAddCartAR")
        }
        
        // MARK:- TODO:- This Line for adding Geusters.
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
        
        GetData()
    }
    
    @IBAction func BTNPlus (_ sender:Any) {
        if productdetalisview.ProductCout.text == "--" {
            ProductDetailsViewController.count = 1
            productdetalisview.ProductCout.text = "\(ProductDetailsViewController.count)"
            productdetalisview.ProductPriceLabel.text = "\(ProductDetailsViewController.onece!.price!) ج٫م"
        }
        else {
            ProductDetailsViewController.count += 1
            productdetalisview.ProductCout.text = "\(ProductDetailsViewController.count)"
            productdetalisview.ProductPriceLabel.text = "\((Int(ProductDetailsViewController.onece!.price!))! * ProductDetailsViewController.count) ج٫م"
        }
    }
    
    @IBAction func BTNMinus (_ sender:Any) {
        if productdetalisview.ProductCout.text == "--" || ProductDetailsViewController.count < 0 || ProductDetailsViewController.count == 0  || productdetalisview.ProductCout.text == "1"{
            productdetalisview.ProductCout.text = "--"
            productdetalisview.ProductPriceLabel.text = "0 ج٫م"
        }
        else {
            ProductDetailsViewController.count -= 1
            productdetalisview.ProductCout.text = "\(ProductDetailsViewController.count)"
            productdetalisview.ProductPriceLabel.text = "\((Int(ProductDetailsViewController.onece!.price!))! * ProductDetailsViewController.count) ج٫م"
        }
    }
    
    @IBAction func BTNDisActiveHeart (_ sender:Any) {
        let data : [String:String] = [
                    "Pdescount":(ProductDetailsViewController.onece!.Pdescount!),
                    "category": (ProductDetailsViewController.onece!.catagory!),
                    "date": (ProductDetailsViewController.onece!.date!),
                    "description": (ProductDetailsViewController.onece!.describtion!),
                    "image": (ProductDetailsViewController.onece!.ImageName!),
                    "pid": (ProductDetailsViewController.onece!.id!),
                    "pname": (ProductDetailsViewController.onece!.Name!),
                    "price": (ProductDetailsViewController.onece!.price!),
                    "time": (ProductDetailsViewController.onece!.time!)
              ]
        
        FireBase.writeInsideChild(childName: "Fav", childID: UserTelephone, productchild: (ProductDetailsViewController.onece!.id!), value: data)
        
            self.productdetalisview.ButtonEmptyLove.isEnabled = false
            self.productdetalisview.ButtonEmptyLove.isHidden = true
            self.productdetalisview.ButtonLoveActive.isHidden = false
            self.productdetalisview.ButtonLoveActive.isEnabled = true
    }
    
    @IBAction func BTNActiveHeart (_ sender:Any) {
        FireBase.deleteinsidechild(childName: "Fav", ChildId: UserTelephone, childProduct: ProductDetailsViewController.onece!.id!)
        
        self.productdetalisview.ButtonEmptyLove.isEnabled = true
        self.productdetalisview.ButtonEmptyLove.isHidden = false
        self.productdetalisview.ButtonLoveActive.isHidden = true
        self.productdetalisview.ButtonLoveActive.isEnabled = false
    }
    
    @IBAction func BTNAddToCart (_ sender:Any) {
        if productdetalisview.ProductCout.text == "--" {
            Tools.createAlert(Title: "Attention".localized , Mess: "AskAmmount".localized, ob: self)
        }
        else {
            AddToCart()
        }
    }
    
    func GetData() {
        productdetalisview.ProductTitleLabel.text = ProductDetailsViewController.onece?.Name
        productdetalisview.ProductPriceLabel.text = "0 ج٫م"
        productdetalisview.ProductDetailsLabel.text = ProductDetailsViewController.onece?.describtion
        productdetalisview.ProductCover.image = ProductDetailsViewController.onece?.Image
        
        //Tools.getPhoto(URL: ProductDetailsViewController.onece!.ImageName!, Image: productdetalisview.ProductCover)
        
        if ProductDetailsViewController.onece?.LoveStatus == true {
            self.productdetalisview.ButtonEmptyLove.isEnabled = false
            self.productdetalisview.ButtonEmptyLove.isHidden = true
            self.productdetalisview.ButtonLoveActive.isHidden = false
            self.productdetalisview.ButtonLoveActive.isEnabled = true
        }
        else {
            self.productdetalisview.ButtonEmptyLove.isEnabled = true
            self.productdetalisview.ButtonEmptyLove.isHidden = false
            self.productdetalisview.ButtonLoveActive.isHidden = true
            self.productdetalisview.ButtonLoveActive.isEnabled = false
        }
        
        /*FireBase.checkisAdded1(childName: "Fav", childId: UserTelephone, k: "pid", v: ProductDetailsViewController.onece!.id!) { (query) in
            self.productdetalisview.ButtonEmptyLove.isEnabled = false
            self.productdetalisview.ButtonEmptyLove.isHidden = true
            self.productdetalisview.ButtonLoveActive.isHidden = false
            self.productdetalisview.ButtonLoveActive.isEnabled = true
        }*/
    }
    
    func AddToCart() {
        let data : [String:String] = [
                                        "Pdescount":ProductDetailsViewController.onece!.Pdescount!,
                                        "category": ProductDetailsViewController.onece!.catagory!,
                                        "date": ProductDetailsViewController.onece!.date!,
                                        "description": ProductDetailsViewController.onece!.describtion!,
                                        "image": ProductDetailsViewController.onece!.ImageName!,
                                        "pid": ProductDetailsViewController.onece!.id!,
                                        "pname": ProductDetailsViewController.onece!.Name!,
                                        "price": ProductDetailsViewController.onece!.price!,
                                        "time": ProductDetailsViewController.onece!.time!,
                                        "qunatity": productdetalisview.ProductCout.text!
                                    ]
               
        FireBase.checkisAdded(childName: "Cart List", childId: "User View", childKey: UserTelephone, TravelId: ProductDetailsViewController.onece!.id!) { (snapshot) in
                   
               FireBase.writeInsideChild2(childName: "Cart List", childID: "User View", productchild: UserTelephone,TravelId: ProductDetailsViewController.onece!.id!, value: data)
                   
           }
    }
    
    // MARK:- TODO:- This Method For Add GuesterAction
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
