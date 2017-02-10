//
//  ItemCellViewCtrl.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 21/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var labelapp: UILabel!
    @IBOutlet weak var imgcheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
