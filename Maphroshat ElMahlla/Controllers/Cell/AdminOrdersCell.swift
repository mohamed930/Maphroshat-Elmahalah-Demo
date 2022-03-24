//
//  AdminOrdersCell.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 9/16/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class AdminOrdersCell: UITableViewCell {
    
    @IBOutlet weak var NameTextField: UILabel!
    @IBOutlet weak var PhoneTextField: UILabel!
    @IBOutlet weak var ShippingAddressTextField: UILabel!
    @IBOutlet weak var TotalAmountTextField: UILabel!
    @IBOutlet weak var OrderTimeTextField: UILabel!
    @IBOutlet weak var ShowOrderButton: UIButton!
    @IBOutlet weak var StateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if "lang".localized == "ar" {
            ShowOrderButton.setTitle("اظهر منتجات المستخدم", for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}
