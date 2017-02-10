//
//  BatteryInfo.swift
//  BatterySaver
//
//  Created by Jérémy Kerbidi on 27/09/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit

class BatteryInfo {
    var Device: UIDevice!
    static var test: Int = 10
    
    init(){
        self.Device = UIDevice.current
        self.Device.isBatteryMonitoringEnabled = true
    }
    
    public func BatteryRemaining() -> String {
        let battery_level = UIDevice.current.batteryLevel * 100
        let aproximatly_time_sec:Float = 69840
        let remaining_time: Int64
        let time_format: String
        
        remaining_time = Int64((battery_level * aproximatly_time_sec) / 100)
        
        if (remaining_time > 0){
            
            let min = convertDateFormater(date: "\((remaining_time % 3600) / 60)")
            time_format = "bigPercentRemaining".localized+" : \(remaining_time / 3600)H\(min)"
        }else {
            time_format = ""
        }
        
        return time_format
    }
    
    func convertDateFormater(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        guard let date = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.dateFormat = "mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: date)

        return timeStamp
    }
    
    // call each frame
    public func BatteryLevel() -> Int {
        
        let current = Device.batteryLevel * 100
        
        if (current > 0){
            return Int(current)
        }
        return 0
    }
    
    public func Test(lol: Int) {
        BatteryInfo.test = lol
    }
    
    public func toggleStatus(img:UIImageView, percent: UILabel, remaining: UILabel) {
        
        if (BatteryState().0 == 1){
            img.isHidden = true
            percent.isHidden = false
            remaining.text = BatteryRemaining()
        }
        if (BatteryState().0 == 2) {
            img.isHidden = false
            percent.isHidden = true
            remaining.text = BatteryState().1
        }
        if (BatteryState().0 == 3) {
            img.isHidden = false
            percent.isHidden = true
            remaining.text = BatteryState().1
        }
    }
    
    public func toggleStatus() -> (Int, String) {
        let state = self.Device.batteryState.hashValue
        
        switch state {
        case 1:
            return (state, BatteryRemaining())
        case 2 :
            return (state, "chargeOnCharge".localized)
        case 3 :
            return (state, "notifBatterycharged".localized)
        default:
            return (state, "")
        }
    }
    
    public func BatteryState() -> (Int, String) {
        
        let state = self.Device.batteryState.hashValue
        
        switch state {
        case 1 :
            return (state, "chargeHealthScore".localized)
        case 2 :
            return (state, "chargeOnCharge".localized)
        case 3 :
            return (state, "notifBatterycharged".localized)
        default: break
        }
        
        return (state, "")
    }
}
