//
//  GameCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 12/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.text = "statusListPlay2048".localized
        let userdef = UserDefaults.standard
        
        if userdef.value(forKey: "tuto") != nil {
            self.theView.mask = nil
        }
        else {
        let mask = UIView(frame: CGRect(x: self.theView.frame.origin.x, y: self.theView.frame.origin.y, width: self.theView.frame.size.width, height: self.theView.frame.size.height))
        mask.backgroundColor = UIColor.black
        //mask.layer.zPosition = 1
        mask.alpha = 0.2
            if #available(iOS 9.0, *) {
                self.theView.mask = mask
            }
        }
        //self.theView.layer.zPosition = 0

    }
}
