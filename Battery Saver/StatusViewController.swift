//
//  FirstViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import UserNotifications
import UserNotificationsUI
import SwiftOverlays
import Alamofire
import JASON

class StatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var BatteryLevel: UILabel!
    @IBOutlet weak var Remaining: UILabel!
    @IBOutlet weak var table_status: UITableView!
    @IBOutlet weak var BatteryChargeOn: UIImageView!
    @IBOutlet weak var Percent: UILabel!
    @IBOutlet weak var flash: UIImageView!
    @IBOutlet weak var tutoHand: UIImageView!
    @IBOutlet weak var tutoLabel: UILabel!
    @IBOutlet weak var titlePage: UILabel!
    
    var battery_info: BatteryInfo!
    var networkInfo: NetworkInfo!
    var tools: Tools!
    var Device: UIDevice!
    var gradient: CAGradientLayer!
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var gtracker: TrackerGoogle!
    var tutoRun: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        let annoy = AnnoyingNotif(view: self)
        annoy.launchPopUpMode()
        self.titlePage.text = "regPageStatus".localized
        self.tutoLabel.text = "tutoappuie".localized
        
        //set tracker
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "Status")
        
        let userdef = UserDefaults.standard
        
        if (userdef.value(forKey: "tuto") != nil) {
            self.tutoRun = false
        }
        else {
            self.tutoRun = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.BatteryLevel.alpha = 1.0
            }, completion: nil)
       })
        
        self.tools = Tools()
        self.networkInfo = NetworkInfo()
        self.BatteryLevel.layer.zPosition = 1
        self.battery_info = BatteryInfo()
        _ = self.battery_info.BatteryRemaining()
        self.BatteryLevel.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryState), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevel), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appClose), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
       
        // ---------
        
        self.table_status.layer.zPosition = 2

        let back = BackgroundAction(controller: self)
        back.monitoring()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnCharge))
        self.BatteryLevel.addGestureRecognizer(gesture)
        self.setupSwipeControls()
        self.notificationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        let userdef = UserDefaults.standard
        
        if (userdef.value(forKey: "tuto") == nil) {
            
            // animation for the hand
            let oldpos = self.tutoHand.center.y
            UIView.animate(withDuration: 1, delay: 0.3, options: [.curveLinear, .repeat, .autoreverse], animations: {
                self.tutoHand.center.y += 20
                if (self.tutoHand.center.y == oldpos+20) {
                    self.tutoHand.center.y = oldpos
                }
            }, completion: nil)
        }
    }
    
    @objc private func appClose() {
        
        // save last openning
        let userdef = UserDefaults.standard
        
        if let o : Int = userdef.value(forKey: "open") as! Int? {
            
            let l = o + 1
            userdef.set(l, forKey: "open")
            userdef.synchronize()
        }
        else {
            userdef.set(1, forKey: "open")
            userdef.synchronize()
        }
    }
    
    @available(iOS 10.0, *)
    func Notif(title: String, body: String, id: String, requestId: String) {
        
        let center = UNUserNotificationCenter.current()
        let highFiveAction = UNNotificationAction(identifier: id, title: title, options: [])
        let category = UNNotificationCategory(identifier: "UYLReminderCategory", actions: [highFiveAction], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
        center.setNotificationCategories([category])
        
        // 2
        let highFiveContent = UNMutableNotificationContent()
        highFiveContent.title = title
        highFiveContent.body = body
        
        // 3
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // 4
        let highFiveRequestIdentifier = requestId
        let highFiveRequest = UNNotificationRequest(identifier: highFiveRequestIdentifier, content: highFiveContent, trigger: trigger)
        center.add(highFiveRequest) { (error) in
            // handle the error if needed
            print("\(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func reinstateBackgroundTask() {
        if (backgroundTask == UIBackgroundTaskInvalid) {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
            assert(backgroundTask != UIBackgroundTaskInvalid)
        }
    }

    @objc private func tutomem() {
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc private func batteryState() {
        self.battery_info.toggleStatus(img: self.BatteryChargeOn, percent: self.Percent, remaining: self.Remaining)
    }
    
    @objc private func batteryLevel() {
        self.BatteryLevel.text = String(self.battery_info.BatteryLevel())
        self.view.animateLayerGradient(gradient: self.gradient, lvl: self.battery_info.BatteryLevel())
        self.gradient.animation(forKey: "animateGradient")
    }
    
    func tapOnCharge() {
         self.tabBarController?.selectedIndex = 1
    }
    
    func notificationManager() {
        
        if #available(iOS 10.0, *) {
            
            if (self.battery_info.BatteryLevel() < 20) {
                self.Notif(title: "notifBatteryLow".localized, body: "notifbatrunninglow".localized, id: "low", requestId: "sampleBatLowRequest")
            }
            
            if (self.battery_info.BatteryState().0 == 3) {
                self.Notif(title: "notifBatterycharged".localized, body: "notifYourbatteryisnowcharged".localized, id: "full", requestId: "sampleBatFullRequest")
            }
            
        }
        else {
            if (self.battery_info.BatteryLevel() < 20) {
                let notification = UILocalNotification()
                notification.alertBody =  "notifbatrunninglow".localized
                notification.alertAction = "open"
                notification.userInfo = ["title": "notifBatteryLow".localized, "UUID": "low"]
                UIApplication.shared.scheduleLocalNotification(notification)
            }
            if (self.battery_info.BatteryState().0 == 3) {
                let notification = UILocalNotification()
                notification.alertBody =  "notifYourbatteryisnowcharged".localized
                notification.alertAction = "open"
                notification.userInfo = ["title": "notifBatterycharged".localized, "UUID": "full"]
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
        
    func setupSwipeControls() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.leftCommand(r:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        if (self.tutoRun == true) {
            return
        }
        self.gtracker.setEvent(category: "status", action: "swipe_charge", label: "swipe")
        self.tabBarController?.selectedIndex = 1
    }
    
    // Start Monitors here
    override func viewWillAppear(_ animated: Bool) {
        
        let userdef = UserDefaults.standard
        
        if (userdef.value(forKey: "tuto") != nil) {
            self.tutoRun = false
            self.tutoHand.isHidden = true
            self.tutoLabel.isHidden = true
            
            for item in self.view.subviews {
                if (item.tag == 142) {
                    item.removeFromSuperview()
                }
            }
        }
        else {
            self.tutoRun = true
            self.tutoHand.isHidden = false
            self.tutoLabel.isHidden = false
            self.tutoLabel.layer.zPosition = 3
            self.tutoHand.layer.zPosition = 3
            
            let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            v.backgroundColor = UIColor.black
            v.alpha = 0.2
            self.tabBarController?.tabBar.mask = v
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
            
            let mask = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            mask.backgroundColor = UIColor.black
            mask.layer.zPosition = 1
            mask.alpha = 0.8
            mask.tag = 142
            let g = UITapGestureRecognizer(target:self, action: #selector(self.tutomem))
            mask.addGestureRecognizer(g)
            self.view.addSubview(mask)
        }
        
        self.tools.animateTable(table: self.table_status)
        self.BatteryLevel.text = String(self.battery_info.BatteryLevel())
        self.battery_info.toggleStatus(img: self.BatteryChargeOn, percent: self.Percent, remaining: self.Remaining)
        
        self.gradient = self.view.layerGradient()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if (self.tutoRun == true) {
            return
        }
        
       if (segue.identifier == "ShowMemory") {
            self.gtracker.setEvent(category: "status", action: "rame", label: "click")
            self.tabBarController?.selectedIndex = 2
        }
        if (segue.identifier == "ShowHardDrive") {
            self.gtracker.setEvent(category: "status", action: "harddrive", label: "click")
            self.tabBarController?.selectedIndex = 2
        }
        if (segue.identifier == "ShowData") {
            self.gtracker.setEvent(category: "status", action: "data", label: "click")
            self.tabBarController?.selectedIndex = 3
        }
        if (segue.identifier == "ShowMore") {
            self.gtracker.setEvent(category: "status", action: "2048", label: "click")
            let game = NumberTileGameViewController(dimension: 4, threshold: 2048)
            self.present(game, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let additionalSeparatorThickness = CGFloat(5)
        let additionalSeparator = UIView(frame: CGRect(x: 0, y: (cell.frame.size.height - additionalSeparatorThickness) + 1, width: cell.frame.size.width, height: additionalSeparatorThickness))
        additionalSeparator.backgroundColor = UIColor.clear
        additionalSeparator.alpha = CGFloat(0.5)
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.contentView.addSubview(additionalSeparator)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 0.3)
        if let indexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
       switch indexPath.row {
            case 3:
                return CGFloat(68)
            case 4:
                return CGFloat(100)
            default:
                break
        }
        
        return CGFloat(77) //Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()

        
        switch indexPath.row {
            case 0:
                cell = self.table_status.dequeueReusableCell(withIdentifier: "MemoryUsed")!
                let userdef = UserDefaults.standard

                if (userdef.value(forKey: "tuto") != nil) {
                    cell.mask = nil
                    cell.contentView.mask = nil
                }
            case 1:
                cell = self.table_status.dequeueReusableCell(withIdentifier: "DataPhone")!
                let userdef = UserDefaults.standard

                if (userdef.value(forKey: "tuto") != nil) {
                    cell.mask = nil
                    cell.contentView.mask = nil
                }
            case 2:
                cell = self.table_status.dequeueReusableCell(withIdentifier: "HardDrive")!
                let userdef = UserDefaults.standard

                if (userdef.value(forKey: "tuto") != nil) {
                    cell.mask = nil
                    cell.contentView.mask = nil
                }
            case 3:
                cell = self.table_status.dequeueReusableCell(withIdentifier: "Game")!
                let userdef = UserDefaults.standard

                if (userdef.value(forKey: "tuto") != nil) {
                    cell.mask = nil
                    cell.contentView.mask = nil
                }
           case 4:
                cell = self.table_status.dequeueReusableCell(withIdentifier: "Banner")!
                let bannerview = GADNativeExpressAdView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
                
                let userdef = UserDefaults.standard
                
                if (userdef.value(forKey: "tuto") != nil) {
                    cell.mask = nil
                }
                else {
                    let mask = UIView(frame: CGRect(x: bannerview.frame.origin.x, y: bannerview.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height))
                    mask.backgroundColor = UIColor.black
                    mask.layer.zPosition = 1
                    mask.alpha = 0.2
                    if #available(iOS 9.0, *) {
                        cell.mask = mask
                    }
                }
                
                let banner = Banner(banner: bannerview, adsize: kGADAdSizeSmartBannerPortrait, controller: self)
                
                cell.addSubview(banner.LoadNative2())
            default:
                break
        }
        
        return cell
    }
    
    @IBAction func MoreApps(_ sender: Any) {
        
        //tracker
        self.gtracker.setEvent(category: "status", action: "moreapps", label: "click")
    }
}
