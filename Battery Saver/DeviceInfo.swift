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
    //var Device: UIDevice!
    internal var Model: String {
        get {
            return  DeviceGuru.hardwareDescription()!
        }
        set (newval){
        }
    }
    internal var Version: String {
        get {
            let Device = UIDevice.current
            Device.isBatteryMonitoringEnabled = true
            
            return Device.systemVersion
        }
        set(newVal) {
           //self.Version = newVal
        }
    }
    internal var Name: String {
        get {
            let Device = UIDevice.current
            Device.isBatteryMonitoringEnabled = true
            
            return Device.name
        }
        set(newVal) {
            //self.Name = newVal
        }
    }
    
    /*internal var Hardware: [String: String] {
        get {
            return self.Hardware
        }
        set (newVal) {
            self.Hardware = newVal
        }
    }*/
    
    internal var IPaddr: String {
        get {
            return ""
        }
        set (newVal) {
            //self.IPaddr = newVal
        }
    }
    
    internal var carrierName: String {
        get {
            return ""
        }
        set (newVal) {
            //self.carrierName = newVal
        }
    }
    
    init(){
    }
}
