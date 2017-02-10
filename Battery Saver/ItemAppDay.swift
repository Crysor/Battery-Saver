//
//  ItemAppDay.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 09/01/2017.
//  Copyright © 2017 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import Alamofire
import JASON

class ItemAppDay {
    
    var URLS: [String]!
    var images = [UIImage]()
    
    init(urls: [String], table: UITableView) {
        self.URLS = urls
        
    }
}
