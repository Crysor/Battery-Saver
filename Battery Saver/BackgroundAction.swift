//
//  BackgroundAction.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 16/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import UserNotificationsUI

class BackgroundAction {
    
    var ctrl: UIViewController!
    var tools: Tools!
    static var PhonePacket: Int64 = 0
    static var WifiPacket: Int64 = 0
    var HistoWifi: [Double]!
    var HistoPhone: [Double]!
    var networkInfo: NetworkInfo!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    static var once: Bool = true

    
    init(controller: UIViewController) {
        self.ctrl = controller
        self.tools = Tools()
        self.networkInfo = NetworkInfo()
        self.HistoWifi = [Double]()
        self.HistoPhone = [Double]()
        
        let today = DateFormatter()
        today.dateFormat = "dd/MM/yy"
        let todayString = today.string(from: Date())
        let userdef = UserDefaults.standard
        
        if let wifi = userdef.value(forKey: "wifi-historic-"+todayString) {
            self.HistoWifi = wifi as! [Double]
        }
        else {
            self.HistoWifi = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }
        
        if let phone = userdef.value(forKey: "phone-historic-"+todayString) {
            self.HistoPhone = phone as! [Double]
        }
        else {
            self.HistoPhone = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }
    }
    
    public func monitoring() {
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(dataMonitoringBackground), userInfo: nil, repeats: true)
    }
    
    private func saveLastOpen() {
        let user = UserDefaults.standard
        let today = DateFormatter()
        today.dateFormat = "dd/MM/yy"
        let todayString = today.string(from: Date())
        
        user.set("last-\(todayString)", forKey: "lastopen")
        user.synchronize()
    }

    private func commitSave() {
                
        self.HistoWifi.remove(at: 0)
        self.HistoPhone.remove(at: 0)
        
        guard self.HistoWifi != nil else {
            return
        }
        
        guard self.HistoPhone != nil else {
            return
        }
        
        if (BackgroundAction.PhonePacket >= 0) {
            self.HistoPhone.append(Double(BackgroundAction.PhonePacket))
        }
        if (BackgroundAction.WifiPacket >= 0) {
            self.HistoWifi.append(Double(BackgroundAction.WifiPacket))
        }
        self.pushSave()
    }
    
    private func pushSave() {
        
        guard self.HistoWifi != nil else {
            return
        }
        
        guard self.HistoPhone != nil else {
            return
        }
        
        self.saveHour()
        
        let user = UserDefaults.standard
        let today = DateFormatter()
        today.dateFormat = "dd/MM/yy"
        let todayString = today.string(from: Date())
        
        user.set(self.HistoWifi, forKey: "wifi-historic-"+todayString)
        user.set(self.HistoPhone, forKey: "phone-historic-"+todayString)
        user.synchronize()
    }
    
    private func saveHour() {
        
        let Userdef = UserDefaults.standard
        var hours = [String]()
        let date = Date()
        
        let df = DateFormatter()
        let c = Calendar.current
        df.dateFormat = "h a"
        
        for i in -6...0 {
            let before = c.date(byAdding: .hour, value: i, to: date)
            hours.append(df.string(from: before!))
        }
        Userdef.set(hours, forKey: "tabhours")
        Userdef.synchronize()
    }
    
    private func checkChange() -> Bool {
        
        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let hnow = cal.component(.hour, from: date)
        var oldh: Int
        let userdef = UserDefaults.standard
        
        if let hourold = userdef.value(forKey: "hour") {
            oldh = hourold as! Int
        }
        else {
            oldh = hnow - 1
        }
        
        if (hnow != oldh) {
            userdef.set(hnow, forKey: "hour")
            userdef.synchronize()
            return true
        }
        
        return false 
    }
    
    @available(iOS 10.0, *)
    func Notif(title: String, body: String, id: String, requestId: String) {
        
        let center = UNUserNotificationCenter.current()
        let highFiveAction = UNNotificationAction(identifier: id, title: title, options: [])
        let category = UNNotificationCategory(identifier: "UYLReminderCategory", actions: [highFiveAction], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
        center.setNotificationCategories([category])
        
        let highFiveContent = UNMutableNotificationContent()
        highFiveContent.title = title
        highFiveContent.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let highFiveRequestIdentifier = requestId//"sampleBatLowRequest"
        let highFiveRequest = UNNotificationRequest(identifier: highFiveRequestIdentifier, content: highFiveContent, trigger: trigger)
        center.add(highFiveRequest) { (error) in
            print("\(error)")
        }
    }
    
    private func ckeckOpening() {
        
        let userdef = UserDefaults.standard
        
        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let nowday = cal.component(.day, from: date)
        let nowHour = cal.component(.hour, from: date)
        
        if let sday: Int = userdef.value(forKey: "daysave") as! Int? {
            if (sday != nowday) {
                
                if ((nowday - sday) == 3) {

                    if #available(iOS 10.0, *) {
                        self.Notif(title: "notifBoostYourPhoneLifetime".localized, body: "notifTaptoboostyourphone".localized, id: "clean", requestId: "sampleBoostRequest")
                    } else {
                        // Fallback on earlier versions
                    }
                    userdef.set(nowday, forKey: "daysave")
                    userdef.synchronize()
                }
                else if ((nowday - sday) >= 5) {
                    if #available(iOS 10.0, *) {
                        self.Notif(title: "notifBoostYourPhoneLifetime".localized, body: "notifTaptoboostyourphone".localized, id: "clean", requestId: "sampleBoostRequest")
                    } else {
                        // Fallback on earlier versions
                    }
                    userdef.set(nowday, forKey: "daysave")
                    userdef.synchronize()
                }
                else {
                    let d = sday + 1
                    userdef.set(d, forKey: "daysave")
                    userdef.synchronize()
                }
            }
        }
        else {
            userdef.set(nowday, forKey: "daysave")
            userdef.synchronize()
        }
        
        if (nowHour == 18 && BackgroundAction.once) {
                BackgroundAction.once = false
                if #available(iOS 10.0, *) {
                    self.Notif(title: "notifFeeling2048".localized, body: "notifTapeHeretoplay".localized, id: "2048", requestId: "sampleGameRequest")
                } else {
                    let notification = UILocalNotification()
                    notification.alertBody =  "notifTapeHeretoplay".localized// text that will be displayed in the notification
                    notification.alertAction = "open"// text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                    notification.userInfo = ["title": "notifFeeling2048".localized , "UUID": "gameNotif"] // assign a unique identifier to the notification so that we can retrieve it later
                    UIApplication.shared.scheduleLocalNotification(notification) //scheduleLocalNotification(notification)
                }
        }
    }
    
    @objc private func dataMonitoringBackground(){
        
        switch UIApplication.shared.applicationState {
        case .active:
            self.ckeckOpening()
            BackgroundAction.PhonePacket += self.networkInfo.getPhonePacket(data: self.networkInfo.getPhoneData(reset: false).0)
            BackgroundAction.WifiPacket += self.networkInfo.getWifiPacket(data: self.networkInfo.getWifiData(reset: false).0)
            if (self.checkChange()){
                self.saveLastOpen()
                self.tools.memIndex()
                self.commitSave()
            }
        case .background:
            self.ckeckOpening()
            BackgroundAction.PhonePacket += self.networkInfo.getPhonePacket(data: self.networkInfo.getPhoneData(reset: false).0)
            BackgroundAction.WifiPacket += self.networkInfo.getWifiPacket(data: self.networkInfo.getWifiData(reset: false).0)
            if (self.checkChange()){
                self.saveLastOpen()
                self.tools.memIndex()
                self.commitSave()
            }
        case .inactive:
            self.ckeckOpening()
            BackgroundAction.PhonePacket += self.networkInfo.getPhonePacket(data: self.networkInfo.getPhoneData(reset: false).0)
            BackgroundAction.WifiPacket += self.networkInfo.getWifiPacket(data: self.networkInfo.getWifiData(reset: false).0)
            if (self.checkChange()){
                self.saveLastOpen()
                self.tools.memIndex()
                self.commitSave()
            }
        }
    }
}
