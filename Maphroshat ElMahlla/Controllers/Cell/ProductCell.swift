//
//  ProductCell.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var ProductImage:  UIImageView!
    @IBOutlet weak var ProductTitle:  UILabel!
    @IBOutlet weak var OldPriceLabel: UILabel!
    @IBOutlet weak var NewPriceLabel: UILabel!
    @IBOutlet weak var LoveButton: UIButton!
    @IBOutlet weak var EmptyLoveButton: UIButton!
    @IBOutlet weak var BTNAddCart: UIButton!
    
    @IBOutlet weak var ContainerView:UIView!
    
    @IBOutlet weak var ImageHight: NSLayoutConstraint!
    
    var onece = Products()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: BTNAddCart, ImageName: "BTNAddCartCellAr")
        }
        else {
            Tools.SetButtonImage(ButtonName: BTNAddCart , ImageName: "BTNAddCart")
        }
        
        ImageHight.constant = 0.3 * ContainerView.frame.height
        ProductImage.layer.cornerRadius = 15.0
        ContainerView.layer.cornerRadius = 15.0
    }

    @IBAction func BTNAddToCart(_ sender:Any) {
        
        let data : [String:String] = [
              "Pdescount":onece.Pdescount!,
              "category": onece.catagory!,
              "date": onece.date!,
              "description": onece.describtion!,
              "image": onece.ImageName!,
              "pid": onece.id!,
              "pname": onece.Name!,
              "price": onece.price!,
              "time": onece.time!,
              "qunatity": "1"
        ]
        
        FireBase.checkisAdded(childName: "Cart List", childId: "User View", childKey: UserTelephone, TravelId: onece.id!) { (snapshot) in
            
            FireBase.writeInsideChild2(childName: "Cart List", childID: "User View", productchild: UserTelephone,TravelId: self.onece.id!, value: data)
            
        }
    }
    
    /*@IBAction func BTNLoved(_ sender:UIButton) {
        
     let data : [String:String] = [
                    "Pdescount":onece.Pdescount!,
                    "category": onece.catagory!,
                    "date": onece.date!,
                    "description": onece.describtion!,
                    "image": onece.ImageName!,
                    "pid": onece.id!,
                    "pname": onece.Name!,
                    "price": onece.price!,
                    "time": onece.time!
              ]

            FireBase.writeInsideChild(childName: "Fav", childID: UserTelephone, productchild: onece.id!, value: data)

            self.EmptyLoveButton.isEnabled = false
            self.EmptyLoveButton.isHidden = true
            self.LoveButton.isHidden = false
            self.LoveButton.isEnabled = true
    }
    
    @IBAction func BTNLovedActice(_ sender:UIButton) {
        FireBase.deleteinsidechild(childName: "Fav", ChildId: UserTelephone, childProduct: self.onece.id!)
            self.LoveButton.isEnabled = false
            self.LoveButton.isHidden = true
            self.EmptyLoveButton.isHidden = false
            self.EmptyLoveButton.isEnabled = true
    }*/
}
