//
//  SystemeCellViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 31/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit

class SystemeCellViewController: UITableViewCell {
    
    @IBOutlet weak var Info: UILabel!
    @IBOutlet weak var data: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
