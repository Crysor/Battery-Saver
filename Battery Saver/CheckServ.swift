//
//  CheckServ.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 19/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON

class CheckServ {
    
    var State: Int!
    
    init() {
        self.State = 0
    }
    
    public func checkLocal() -> Bool {
        
        let local: String = "\(Locale.current)"
        
        if (local.hasPrefix("en_US")) {
            return true
        }
        
        return false
    }
    /*
    public func launch(labels: [UILabel]) {
        
        let local: String = "\(Locale.current)"
        
        if (local.hasPrefix("en_US")) {
            
            print("c'est bon")
            Alamofire.request("http://www.spicy-apps.com/review/review.php", method: .get).responseJSON { response in
                print("co ?")
                if let json = response.result.value {
         
                    let all = JSON(json)
                    
                    //DispatchQueue.main.async {
                        
                    self.State = all["state"].intValue
                       // print("State \(self.State)")
                    //}
                }
            }
        }
    }*/
}
