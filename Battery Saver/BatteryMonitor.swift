//
//  BatteryMonitor.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 10/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit

class MonitorManager {
    
    var Selector: Selector
    var Target: UIViewController
    
    init(target: UIViewController, sel: Selector) {
        self.Target = target
        self.Selector = sel
        
    }
    
    public func MonitorHandler() -> Timer {
        return Timer.scheduledTimer(timeInterval: 1.0, target: self.Target, selector: self.Selector, userInfo: nil, repeats: true)
    }
    
}
