//
//  CatagoryCell.swift
//  Maphroshat ElMahlla
//
//  Created by Mohamed Ali on 8/27/20.
//  Copyright © 2020 Mohamed Ali. All rights reserved.
//

import UIKit

class CatagoryCell: UICollectionViewCell {
    
    @IBOutlet weak var CatagoryCover:UIImageView!
    @IBOutlet weak var CatagoryTitle:UILabel!
    @IBOutlet weak var ContainerView:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ContainerView.layer.cornerRadius = 15.0
    }

}
