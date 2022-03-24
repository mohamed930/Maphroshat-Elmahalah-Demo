//
//  CartViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 9/4/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import ProgressHUD
import FirebaseDatabase

class CartViewController: UIViewController {
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var CartArray = Array<Cart>()
    var FinalPrice = 0
    
    
    var cartview: CartView! {
        guard isViewLoaded else { return nil }
        return (view as! CartView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: cartview.BTNNext , ImageName: "BTNNextAr")
        }
        
        self.cartview.BTNNext.isEnabled = false
        
        // MARK:- TODO:- This Line for adding Geusters.
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
                
        cartview.tableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "Cell")
        GetCartList()
    }
    
    @IBAction func BTNNext (_ sender:Any) {
        Tools.createAlert(Title: "Attension".localized, Mess: "ShowMess".localized, ob: self)
    }
    
    func GetCartList() {
        
        self.CartArray.removeAll()
        
        FireBase.checkisEmptyCart(childName: UserTelephone, Label: self.cartview.MessLabel, Collection: self.cartview.tableView) { (snap) in
            
            if snap.hasChildren() {
                self.cartview.BTNNext.isEnabled = true
            }
            
            FireBase.readinsideCart(childUser: UserTelephone, childType: "User View") { (snapshot) in
                let value = snapshot.value as! Dictionary<String,String>
                
                let ob = Cart()
                ob.ProductTitle = value["pname"]!
                ob.Price = value["price"]!
                ob.qunatity = value["qunatity"]!
                ob.id = snapshot.key
                self.FinalPrice += Int(ob.Price!)! * Int(ob.qunatity!)!
                self.CartArray.append(ob)
                self.cartview.tableView.reloadData()
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    
    // MARK:- TODO:- This Method For Add GuesterAction
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!
            CartCell
        
        cell.ProductName.text = CartArray[indexPath.row].ProductTitle
        cell.QuantityLabel.text = "Quantity".localized + "\(CartArray[indexPath.row].qunatity!)"
        cell.FinalPriceLabel.text = "TotalPrice".localized + "\(Int(CartArray[indexPath.row].Price!)! * Int(CartArray[indexPath.row].qunatity!)!) " + "EGP".localized
        
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Attention".localized , message: "DeleteMess".localized, preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            alert.addAction(action1)
            
            let action2 = UIAlertAction(title: "Delete".localized, style: .destructive) { (alert) in
                print("F: \(self.CartArray[indexPath.row].id!)")
                
                RappleActivityIndicatorView.startAnimatingWithLabel("Waiting".localized, attributes: RappleModernAttributes)
                
                Database.database().reference().child("Cart List").child("User View").child(UserTelephone).child("Products").child(self.CartArray[indexPath.row].id!).removeValue { (error, ref) in
                    if error != nil {
                        RappleActivityIndicatorView.stopAnimation()
                        ProgressHUD.showError("Error".localized)
                    }
                    else {
                        RappleActivityIndicatorView.stopAnimation()
                        self.CartArray.removeAll()
                        
                        self.GetCartList()
                    }
                }
            }
            alert.addAction(action2)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
