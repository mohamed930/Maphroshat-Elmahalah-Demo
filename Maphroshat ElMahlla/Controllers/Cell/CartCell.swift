//
//  CartCell.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    @IBOutlet weak var ProductName:UILabel!
    @IBOutlet weak var QuantityLabel:UILabel!
    @IBOutlet weak var FinalPriceLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
}
