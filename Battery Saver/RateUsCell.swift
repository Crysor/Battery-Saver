//
//  RateUsCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 14/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class RateUsCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.text = "moreRateus".localized
    }
}
