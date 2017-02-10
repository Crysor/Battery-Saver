//
//  HardwareSpecification.swift
//  BatterySaver
//
//  Created by Jérémy Kerbidi on 28/09/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation

class HardwareSpecification {
    
    internal var HardwareDetails = [String: String]()
    
    init() {
        self.HardwareDetails = DeviceGuru.hardwareDetails()
    }
}
