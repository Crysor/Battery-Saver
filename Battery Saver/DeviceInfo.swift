//
//  DeviceDetails.swift
//  BatterySaver
//
//  Created by Jérémy Kerbidi on 27/09/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit

class DeviceInfo {
    
    internal var Model: String {
        return  DeviceGuru.hardwareDescription()!
    }
    
    internal var Version: String {
        let Device = UIDevice.current
        Device.isBatteryMonitoringEnabled = true
            
        return Device.systemVersion
    }
    
    internal var Name: String {
        let Device = UIDevice.current
        Device.isBatteryMonitoringEnabled = true
            
        return Device.name
    }
    
    init(){
    }
}
