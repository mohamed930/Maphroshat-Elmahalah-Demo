//
//  HomeViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/28/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import ProgressHUD
import KYDrawerController
import Alamofire
import AlamofireImage
import DropDown
import MOLH

class HomeViewController: UIViewController {
    
    var title1 = ["طقم سرير كبير و اطفال","فوط","كوفرتة و بطانية","روبات","سجاده صلاه","مفارش"]
    var images = ["BigBed","Fwt","batanya","rop","accs","mafrsh"]
    
    var productsArray = Array<Products>()
    var LovedId = Array<String>()
    var ImagesArr = Array<UIImage>()
    static var AdminStatus = false
    let dropDown = DropDown()
    
    static var CheckBack = false
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var homeview: HomeView! {
        guard isViewLoaded else { return nil }
        return (view as! HomeView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK:- TODO:- For Admin Page Back Check.
        if HomeViewController.CheckBack == true {
            // MARK:- TODO:- This Line for adding Geusters.
            screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
            screenedge.edges = .left
            view.addGestureRecognizer(screenedge)
            homeview.ShowMenu.isHidden = true
            homeview.BTNCart.isHidden = true
        }
        else {
            // MARK:- TODO: For Menu Direction.
            let appDel = UIApplication.shared.delegate as! AppDelegate
            
            if "lang".localized == "en" {
                appDel.drawerController.drawerDirection = .left
            }
            else {
                appDel.drawerController.drawerDirection = .right
            }
            homeview.ShowMenu.isHidden = false
            homeview.BTNCart.isHidden  = false
        }
        
        // MARK:- TODO:- For Collection view Regester Cell.
        homeview.CollectionView1.register(UINib(nibName: "CatagoryCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        homeview.CollectionView1?.backgroundColor = UIColor.clear
        homeview.CollectionView1?.backgroundView = UIView(frame: CGRect.zero)
        
        
        homeview.CollectionViewHight.constant = (0.43 * self.view.frame.size.height)
        
        // MARK:- TODO:- Make Action and Design For Search TextField.
        homeview.SearchTextField.layer.backgroundColor = UIColor.white.cgColor
        Tools.setLeftPadding(textField: homeview.SearchTextField, paddingValue: 55, PlaceHolder: "SearchPlaceHolder".localized , Color: UIColor.gray)
        let tab = UITapGestureRecognizer(target: self, action: #selector(goToSearch(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        homeview.SearchButtonIcon.isUserInteractionEnabled = true
        homeview.SearchButtonIcon.addGestureRecognizer(tab)
        
        // MARK:- TODO:- Drop Down Intialize
        if "lang".localized == "ar" {
            dropDown.anchorView = self.homeview.ShowMenu
        }
        else {
            dropDown.anchorView = self.homeview.BTNMore
        }
        dropDown.width = 100.0
        dropDown.dataSource = ["English" , "عربي"]
        dropDown.selectionAction = { (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
          
            if (item == "English") {
                if (MOLHLanguage.currentAppleLanguage() == "en") {
                    ProgressHUD.showError("Your Labguae is already English")
                }
                else {
                    MOLH.setLanguageTo(MOLHLanguage.currentAppleLanguage() == "en" ? "ar" : "en")
                    MOLH.reset()
                }
            }
            else if item == "عربي" {
                if (MOLHLanguage.currentAppleLanguage() == "ar") {
                    ProgressHUD.showError("لغتك بالفعل العربيه")
                }
                else {
                    MOLH.setLanguageTo(MOLHLanguage.currentAppleLanguage() == "en" ? "ar" : "en")
                    MOLH.reset()
                }
            }
            
          
        }
        
    }
    
    @IBAction func ShowSideMenu (_ sender:Any) {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.drawerController.setDrawerState(.opened, animated: true)
    }
    
    @IBAction func BTNCartList (_ sender:Any) {
        
        FireBase.checkisEmptyOrder(childName: UserTelephone) { (result) in
            if result == "Success" {
                Tools.openForm(MainViewName: "Main", FormID: "ShipedView", ob: self)
            }
            else if result == "Falied" {
                Tools.openForm(MainViewName: "Main", FormID: "CartView", ob: self)
            }
        }
    }
    
    @IBAction func BTNShowLan (_ sender:Any) {
        dropDown.show()
    }
    
    func FetchProductData (v:String) {
    
        if !self.productsArray.isEmpty || !self.LovedId.isEmpty {
            self.productsArray.removeAll()
            self.LovedId.removeAll()
        }
        
        FireBase.checkisEmpty(childName: "Products", k: "category", v: v, Label: homeview.MessLabel, Collection: homeview.CollectionView2) { (snap) in
            
            FireBase.readwithcondtion(childName: "Products", k: "category", v: v,condition: 1) { (snapshot) in
                let value = snapshot.value as! Dictionary<String,String>
                
                let ob = Products()
                
                ob.id = value["pid"]! //snapshot.key
                ob.Name = value["pname"]!
                ob.price = value["price"]!
                ob.ImageName = value["image"]!
                
                ob.describtion = value["description"]!
                ob.Pdescount = value["Pdescount"]!
                ob.date = value["date"]!
                ob.time = value["time"]!
                ob.catagory = value["category"]!
                ob.icatagory = value["categoryDialog"]!
                
                AF.request(value["image"]!).responseImage(completionHandler: {
                    (response) in
                    if let image1 = response.value {
                        let size = CGSize(width: 300.0, height: 300.0)
                        let scaleImage = image1.af.imageScaled(to: size)
                        DispatchQueue.main.async {
                            ob.Image = scaleImage
                            self.productsArray.append(ob)
                            self.homeview.CollectionView2.reloadData()
                        }
                        RappleActivityIndicatorView.stopAnimation()
                    }
                })
                
                //RappleActivityIndicatorView.stopAnimation()
            }
            
            if HomeViewController.AdminStatus == false {
                FireBase.readwithoutcondtioninsidechild(childName: "Fav", childId: UserTelephone) { (snapshot) in
                    let value = snapshot.value as! Dictionary<String,String>
                    
                    if value["category"]! == v {
                        self.LovedId.append(value["pname"]!)
                        //self.homeview.CollectionView2.reloadData()
                    }
                }
            }
            for j in self.LovedId {
                print("F: \(j)")
            }
        }
    }
    
    func SearchProduct() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let next = story.instantiateViewController(withIdentifier: "SearchResultView") as! SearchresultViewController
        next.modalPresentationStyle = .fullScreen
        next.GetProductName = self.homeview.SearchTextField.text!
        self.present(next, animated: true, completion: nil)
    }
    
    @objc func BTNLove (_ sender:UIButton) {
        
        let myIndexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell : ProductCell = homeview.CollectionView2.cellForItem(at: myIndexPath as IndexPath) as! ProductCell
    
        productsArray[myIndexPath.row].flag = 0
        
        let data = [
                "Pdescount": productsArray[myIndexPath.row].Pdescount!,
                "category": productsArray[myIndexPath.row].catagory!,
                "date": productsArray[myIndexPath.row].date!,
                "description": productsArray[myIndexPath.row].describtion!,
                "image": productsArray[myIndexPath.row].ImageName!,
                "pid": productsArray[myIndexPath.row].id!,
                "pname": productsArray[myIndexPath.row].Name!,
                "price": productsArray[myIndexPath.row].price!,
                "time": productsArray[myIndexPath.row].time!
            ]
        
        FireBase.writeInsideChild(childName: "Fav", childID: UserTelephone, productchild: productsArray[myIndexPath.row].id!, value: data)

        cell.EmptyLoveButton.isEnabled = false
        cell.EmptyLoveButton.isHidden = true
        cell.LoveButton.isHidden = false
        cell.LoveButton.isEnabled = true
        
        self.productsArray[myIndexPath.row].LoveStatus = true
        
    }
       
    @objc func BTNActiveLove (_ sender:UIButton) {
        
        let myIndexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell : ProductCell = homeview.CollectionView2.cellForItem(at: myIndexPath as IndexPath) as! ProductCell
    
        productsArray[myIndexPath.row].flag = 2
        
        FireBase.deleteinsidechild(childName: "Fav", ChildId: UserTelephone, childProduct: self.productsArray[myIndexPath.row].id!)
        cell.LoveButton.isEnabled = false
        cell.LoveButton.isHidden = true
        cell.EmptyLoveButton.isHidden = false
        cell.EmptyLoveButton.isEnabled = true
        self.productsArray[myIndexPath.row].LoveStatus = false
    }
    
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        //self.dismiss(animated: true, completion: nil)
        Tools.openForm(MainViewName: "Admin View", FormID: "AdminHome", ob: self)
    }
    
    // MARK:- TODO:- Action For Search Products in Firebase.
    @objc func goToSearch(tapGestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        SearchProduct()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        dropDown.hide()
    }

}

extension HomeViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView.tag == 1 {
                return title1.count
            }
            else {
                return productsArray.count
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell: CatagoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CatagoryCell
            
            cell.CatagoryTitle.text = title1[indexPath.row]
            cell.CatagoryCover.image = UIImage(named: images[indexPath.row])
            
            return cell
        }
        else {
            
            let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCell
            
            cell.onece = productsArray[indexPath.row]
            cell.NewPriceLabel.text = "\(productsArray[indexPath.row].price!) ج٫م"
            //Tools.getPhoto(URL: productsArray[indexPath.row].ImageName!, Image: cell.ProductImage)
            cell.ProductImage.image = productsArray[indexPath.row].Image!
            cell.ProductTitle.text = productsArray[indexPath.row].Name
            
            if productsArray[indexPath.row].Pdescount != "" {
                cell.OldPriceLabel.isHidden = false
                Tools.MakeLineThrough(Title: "\(productsArray[indexPath.row].Pdescount!) ج٫م", Label: cell.OldPriceLabel)
            }
            else {
                cell.OldPriceLabel.isHidden = true
            }
            
            if productsArray[indexPath.row].flag == 2 {
                cell.LoveButton.isEnabled = false
                cell.LoveButton.isHidden = true
                cell.EmptyLoveButton.isHidden = false
                cell.EmptyLoveButton.isEnabled = true
                //self.productsArray[indexPath.row].LoveStatus = false
            }
            else {
                cell.EmptyLoveButton.isEnabled = false
                cell.EmptyLoveButton.isHidden = true
                cell.LoveButton.isHidden = false
                cell.LoveButton.isEnabled = true
            }
            
            for j in LovedId {
                if self.productsArray[indexPath.row].Name == j {
                    cell.EmptyLoveButton.isEnabled = false
                    cell.EmptyLoveButton.isHidden = true
                    cell.LoveButton.isHidden = false
                    cell.LoveButton.isEnabled = true
                    self.productsArray[indexPath.row].LoveStatus = true
                    self.productsArray[indexPath.row].flag = 2
                }
            }
            
            /*for i in productsArray {
                for j in LovedId {
                    if i.Name == j {
                        cell.EmptyLoveButton.isEnabled = false
                        cell.EmptyLoveButton.isHidden = true
                        cell.LoveButton.isHidden = false
                        cell.LoveButton.isEnabled = true
                        self.productsArray[indexPath.row].LoveStatus = true
                        self.productsArray[indexPath.row].flag = 2
                    }
                    else {
                        cell.EmptyLoveButton.isEnabled = false
                        cell.EmptyLoveButton.isHidden = true
                        cell.LoveButton.isHidden = false
                        cell.LoveButton.isEnabled = true
                        self.productsArray[indexPath.row].LoveStatus = false
                        self.productsArray[indexPath.row].flag = 0
                    }
                }
                /*if productsArray[indexPath.row].Name == i {
                    cell.EmptyLoveButton.isEnabled = false
                    cell.EmptyLoveButton.isHidden = true
                    cell.LoveButton.isHidden = false
                    cell.LoveButton.isEnabled = true
                    self.productsArray[indexPath.row].LoveStatus = true
                    self.productsArray[indexPath.row].flag = 2
                }
                else {
                    cell.EmptyLoveButton.isEnabled = false
                    cell.EmptyLoveButton.isHidden = true
                    cell.LoveButton.isHidden = false
                    cell.LoveButton.isEnabled = true
                    self.productsArray[indexPath.row].LoveStatus = false
                    self.productsArray[indexPath.row].flag = 0
                }*/
            }*/
            
            cell.LoveButton.tag = indexPath.row
            cell.LoveButton.addTarget(self,
            action: #selector(BTNActiveLove),
            for: .touchUpInside)
            
            cell.EmptyLoveButton.tag = indexPath.row
            cell.EmptyLoveButton.addTarget(self,
            action: #selector(BTNLove),
            for: .touchUpInside)
            
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            homeview.CollectionView2.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            homeview.CollectionView2.dataSource = self
            homeview.CollectionView2.delegate = self
            FetchProductData(v: title1[indexPath.row])
            //print(title1[indexPath.row])
        }
        else {
            if HomeViewController.AdminStatus == false {
                // Open New Form With Product
                ProductDetailsViewController.onece = productsArray[indexPath.row]
                Tools.openForm(MainViewName: "Main", FormID: "ProductDetails", ob: self)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {
            let w1 = homeview.CollectionView1.frame.width - (12 * 2)
            let cell_width = (w1 - (12 * 2)) / 3
            
            return CGSize(width: cell_width, height: homeview.CollectionView1.frame.height)
        }
        else {
            let w1 = homeview.CollectionView2.frame.width - 12
            let cell_width = (w1 - (12 * 2)) / 2
            
            return CGSize(width: cell_width, height: homeview.CollectionView2.frame.height)
        }
    }
    
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        SearchProduct()
        return true;
    }
    
}
