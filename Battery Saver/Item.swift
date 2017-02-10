//
//  Item.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 21/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class ItemTab {
    
    var img: UIImage
    var label: String
    var imgCheck: UIImage
    var row: Int
    
    init(img: UIImage, label: String, imgCheck: UIImage, row: Int) {
        self.img = img
        self.label = label
        self.imgCheck = imgCheck
        self.row = row
    }
}
