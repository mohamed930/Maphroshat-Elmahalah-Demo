//
//  SearchresultViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 1/25/21.
//  Copyright © 2021 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import Firebase
import ProgressHUD
import Alamofire
import AlamofireImage

class SearchresultViewController: UIViewController {
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var GetProductName = String()
    var ResultArr = Array<Products>()
    
    var searchresultview: Searchresultview! {
        guard isViewLoaded else { return nil }
        return (view as! Searchresultview)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK:- TODO:- This Line for adding Geusters.
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: searchresultview.BTNBack , ImageName: "ButtonBackRight")
        }
        
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
        
        searchresultview.SearchTextField.layer.backgroundColor = UIColor.white.cgColor
        Tools.setLeftPadding(textField: searchresultview.SearchTextField, paddingValue: 55, PlaceHolder: "SearchPlaceHolder".localized , Color: UIColor.gray)
        let tab = UITapGestureRecognizer(target: self, action: #selector(goToSearch(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        searchresultview.SearchTextField.isUserInteractionEnabled = true
        searchresultview.SearchIcon.addGestureRecognizer(tab)
        
        searchresultview.collectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        GetSearchedItem()
    }
    
    @IBAction func BTNBack (_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- TODO:- This Method For Add GuesterAction
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- TODO:- Action For Search Products in Firebase.
    @objc func goToSearch(tapGestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.GetProductName = self.searchresultview.SearchTextField.text!
        GetSearchedItem()
    }
    
    func GetSearchedItem() {
        print("You Searched for \(GetProductName)")
        
        if !self.ResultArr.isEmpty {
            self.ResultArr.removeAll()
        }
        
        RappleActivityIndicatorView.startAnimatingWithLabel("Please wait", attributes: RappleModernAttributes)
        
        Database.database().reference().child("Products").queryOrdered(byChild: "pname").queryStarting(atValue: GetProductName).queryEnding(atValue: GetProductName+"\u{f8ff}").observe(.value) { (snap) in
            
            
            if snap.childrenCount <= 0 {
                RappleActivityIndicatorView.stopAnimation()
                self.searchresultview.collectionView.isHidden = true
                self.searchresultview.MessLabel.isHidden = false
                self.searchresultview.MessLabel.text = "Result".localized
            }
            else {
                
                self.searchresultview.collectionView.isHidden = false
                self.searchresultview.MessLabel.isHidden = true
                
                Database.database().reference().child("Products").queryOrdered(byChild: "pname").queryStarting(atValue: self.GetProductName).queryEnding(atValue: self.GetProductName+"\u{f8ff}").observe(.childAdded) { (snapshot) in
                    let result = snapshot.value as! Dictionary<String,String>
                    
                    let ob = Products()
                    ob.id = result["pid"]!
                    ob.Name = result["pname"]!
                    ob.price = result["price"]!
                    ob.Pdescount = result["Pdescount"]!
                    ob.ImageName = result["image"]!
                    
                    ob.describtion = result["description"]!
                    ob.Pdescount = result["Pdescount"]!
                    ob.date = result["date"]!
                    ob.time = result["time"]!
                    ob.catagory = result["category"]!
                    
                    AF.request(result["image"]!).responseImage(completionHandler: {
                        (response) in
                        if let image1 = response.value {
                            let size = CGSize(width: 300.0, height: 300.0)
                            let scaleImage = image1.af.imageScaled(to: size)
                            DispatchQueue.main.async {
                                ob.Image = scaleImage
                                self.ResultArr.append(ob)
                                self.searchresultview.collectionView.reloadData()
                            }
                            RappleActivityIndicatorView.stopAnimation()
                        }
                    })
                    
                    //self.ResultArr.append(ob)
                    //self.searchresultview.collectionView.reloadData()
                    //RappleActivityIndicatorView.stopAnimation()
                    
                }
            }
        }
    }
}

extension SearchresultViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ResultArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCell
        
        cell.onece = ResultArr[indexPath.row]
        cell.NewPriceLabel.text = "\(ResultArr[indexPath.row].price!) ج٫م"
        cell.ProductImage.image = ResultArr[indexPath.row].Image!
        //Tools.getPhoto(URL: ResultArr[indexPath.row].ImageName!, Image: cell.ProductImage)
        cell.ProductTitle.text = ResultArr[indexPath.row].Name
        
        if ResultArr[indexPath.row].Pdescount != "null" {
            cell.OldPriceLabel.isHidden = false
            Tools.MakeLineThrough(Title: "\(ResultArr[indexPath.row].Pdescount!) ج٫م", Label: cell.OldPriceLabel)
        }
        else {
            cell.OldPriceLabel.isHidden = true
        }
        
        cell.EmptyLoveButton.tag = indexPath.row
        cell.EmptyLoveButton.addTarget(self,
        action: #selector(BTNLove),
        for: .touchUpInside)
        
        return cell
    }
    
    @objc func BTNLove (_ sender:UIButton) {
              
        let myIndexPath = NSIndexPath(row: sender.tag, section: 0)
        
        RappleActivityIndicatorView.startAnimatingWithLabel("plaase wait", attributes: RappleModernAttributes)
        Database.database().reference().child("Fav").child(UserTelephone).child(self.ResultArr[myIndexPath.row].id!).removeValue { (error, ref) in
                if error != nil {
                    RappleActivityIndicatorView.stopAnimation()
                    ProgressHUD.showError("You Can't Delete!")
                }
                else {
                    RappleActivityIndicatorView.stopAnimation()
                    self.ResultArr.remove(at: myIndexPath.row)
                }
            }
    }
}

extension SearchresultViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Open New Form With Product
        print("Admin mess: \(AdminStatus1)")
        ProductDetailsViewController.onece = ResultArr[indexPath.row]
        Tools.openForm(MainViewName: "Main", FormID: "ProductDetails", ob: self)
    }
    
}

extension SearchresultViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
    IndexPath) -> CGSize {
        let w1 = searchresultview.collectionView.frame.width - 12
        let cell_width = (w1 - (12 * 2)) / 2
        
        return CGSize(width: cell_width, height: 300.0)
    }
    
}

extension SearchresultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.GetProductName = self.searchresultview.SearchTextField.text!
        self.view.endEditing(true)
        GetSearchedItem()
        return true
    }
}
