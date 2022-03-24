//
//  FavouriteViewController.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 9/4/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit
import RappleProgressHUD
import ProgressHUD
import FirebaseDatabase
import Alamofire
import AlamofireImage

class FavouriteViewController: UIViewController {
    
    var screenedge : UIScreenEdgePanGestureRecognizer!
    
    var FavouritProductsArray = Array<Products>()
    var flag: Bool = false
    var PickedId = String()
    
    var fav_view:FavourtieView! {
        guard isViewLoaded else { return nil }
        return (view as! FavourtieView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if "lang".localized == "ar" {
            Tools.SetButtonImage(ButtonName: fav_view.BTNBack , ImageName: "ButtonBackRight")
        }
        
        // MARK:- TODO:- This Line for adding Geusters.
        screenedge = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Back(_:)))
        screenedge.edges = .left
        view.addGestureRecognizer(screenedge)
        
        fav_view.collectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        
        fav_view.SearrchTextField.layer.backgroundColor = UIColor.white.cgColor
        Tools.setLeftPadding(textField: fav_view.SearrchTextField, paddingValue: 55, PlaceHolder: "SearchPlaceHolder".localized , Color: UIColor.gray)
        let tab = UITapGestureRecognizer(target: self, action: #selector(goToSearch(tapGestureRecognizer:)))
        tab.numberOfTapsRequired = 1
        tab.numberOfTouchesRequired = 1
        fav_view.SearchButtonIcon.isUserInteractionEnabled = true
        fav_view.SearchButtonIcon.addGestureRecognizer(tab)
        
        if flag == false {
            GetFavourits()
        }
    }
    
    @IBAction func BTNAction (_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func GetFavourits () {
        
        FireBase.checkisEmpty1(childName: "Fav",childId: UserTelephone, Label: fav_view.MessLabel, Collection: fav_view.collectionView) { (snapshot) in
            
            FireBase.readwithoutcondtioninsidechild(childName: "Fav", childId: UserTelephone) { (snapshot) in
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
                
                AF.request(value["image"]!).responseImage(completionHandler: {
                    (response) in
                    if let image1 = response.value {
                        let size = CGSize(width: 1000.0, height: 1000.0)
                        let scaleImage = image1.af.imageScaled(to: size)
                        DispatchQueue.main.async {
                            ob.Image = scaleImage
                            self.FavouritProductsArray.append(ob)
                            self.fav_view.collectionView.reloadData()
                        }
                        RappleActivityIndicatorView.stopAnimation()
                    }
                })
                
                //self.FavouritProductsArray.append(ob)
                //self.fav_view.collectionView.reloadData()
                //RappleActivityIndicatorView.stopAnimation()
            }
        }
        
    }
    
    func SearchProduct() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let next = story.instantiateViewController(withIdentifier: "SearchResultView") as! SearchresultViewController
        next.modalPresentationStyle = .fullScreen
        next.GetProductName = self.fav_view.SearrchTextField.text!
        self.present(next, animated: true, completion: nil)
    }
    
    // MARK:- TODO:- This Method For Add GuesterAction
    @objc func Back (_ sender:UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func BTNLove (_ sender:UIButton) {
              
          //let myIndexPath = NSIndexPath(row: sender.tag, section: 0)
          //let indexpath = IndexPath(row: sender.tag, section: 0)
        
        RappleActivityIndicatorView.startAnimatingWithLabel("plaase wait", attributes: RappleModernAttributes)
        PickedId = self.FavouritProductsArray[sender.tag].id!
        Database.database().reference().child("Fav").child(UserTelephone).child(PickedId).removeValue { (error, ref) in
            if error != nil {
                RappleActivityIndicatorView.stopAnimation()
            }
            else {
                // I sea This line in Stackoverflow but it dosn't work.
                //ref.child("Fav").child(UserTelephone).removeAllObservers()
                RappleActivityIndicatorView.stopAnimation()
                self.FavouritProductsArray.removeAll()
                self.flag = true
                //self.FavouritProductsArray.remove(at: sender.tag)
                //let indexpath = IndexPath(row: sender.tag, section: 0)
                //self.fav_view.collectionView.deleteItems(at: [indexpath])
            }
        }
    }
    
    // MARK:- TODO:- Action For Search Products in Firebase.
    @objc func goToSearch(tapGestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        SearchProduct()
    }
}

extension FavouriteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Open New Form With Product
        ProductDetailsViewController.onece = FavouritProductsArray[indexPath.row]
        Tools.openForm(MainViewName: "Main", FormID: "ProductDetails", ob: self)
    }
}

extension FavouriteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FavouritProductsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCell
        
      //  if self.flag == true {
            cell.onece = FavouritProductsArray[indexPath.row]
            cell.NewPriceLabel.text = "\(FavouritProductsArray[indexPath.row].price!) ج٫م"
            //Tools.getPhoto(URL: FavouritProductsArray[indexPath.row].ImageName!, Image: cell.ProductImage)
            cell.ProductImage.image = FavouritProductsArray[indexPath.row].Image!
            cell.ProductTitle.text = FavouritProductsArray[indexPath.row].Name
            cell.LoveButton.isHidden = true
            cell.LoveButton.isEnabled = false
           
            
            if FavouritProductsArray[indexPath.row].Pdescount != "" {
                cell.OldPriceLabel.isHidden = false
                Tools.MakeLineThrough(Title: "\(FavouritProductsArray[indexPath.row].Pdescount!) ج٫م", Label: cell.OldPriceLabel)
            }
            else {
                cell.OldPriceLabel.isHidden = true
            }
            
            cell.EmptyLoveButton.tag = indexPath.row
            cell.EmptyLoveButton.addTarget(self,action: #selector(BTNLove),for: .touchUpInside)
       // }
        
        return cell
    }
}

extension FavouriteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
    IndexPath) -> CGSize {
        let w1 = fav_view.collectionView.frame.width - 12
        let cell_width = (w1 - (12 * 2)) / 2
        
        return CGSize(width: cell_width, height: 300.0)
    }
}

extension FavouriteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        SearchProduct()
        return true
    }
}
