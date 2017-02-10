//
//  MoreAppsCellView.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 27/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class MoreAppsCellView: UITableViewCell {
    
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var editor: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    var rate: Int!
    var Stars = [UIImageView]()
    var getIt: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btn.layer.cornerRadius = 5
        self.picture.layer.cornerRadius = 20
        self.picture.clipsToBounds = true
    }
    
    @IBAction func getItApp(_ sender: Any) {
        
        //TODO popup
        print("get It \(self.getIt)")
        
        if let url = self.getIt {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            // Fallback on earlier versions
            }
        }
    }
}
