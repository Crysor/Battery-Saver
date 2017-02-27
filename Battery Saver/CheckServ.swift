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
}
