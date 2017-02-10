//
//  AppItem.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 27/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class AppItem {
    
    var name: String!
    var editor: String!
    var picture: UIImage!
    var rate: Int!
    var storLink: URL!
    var idApp: String!
    
    init(id: String, name: String, editor: String, rate: String, pic: String, storeLink: String, tab: UITableView) {
        self.name = name
        self.idApp = id
        self.editor = editor
        
        if let Rate = Int(rate) {
            self.rate = Rate
        }
        else {
            self.rate = 0
        }
            
        
        self.storLink = URL(string: storeLink)
        
        let preferences = UserDefaults.standard
        
        if (preferences.object(forKey: id) != nil){
            let Data = preferences.object(forKey: id) as! Data
            self.picture = UIImage(data: Data)
            
            OperationQueue.main.addOperation {
                tab.reloadData()
            }
        }
        else {
            Alamofire.request(pic).responseData { response in
                
                if let data = response.result.value {
                    self.picture = UIImage(data: data)
                
                    let photo = UserDefaults.standard
                    photo.set(data, forKey: id)
                    photo.synchronize()
                }
                
               OperationQueue.main.addOperation {
                    tab.reloadData()
                }
            }
        }
    }
}
