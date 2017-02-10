//
//  TodayViewController.swift
//  BTC Battery Saver
//
//  Created by Jérémy Kerbidi on 07/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var upLoadSpeed: UILabel!
    @IBOutlet weak var downLoadSpeed: UILabel!
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var batteryLvl: UILabel!
    @IBOutlet weak var chargeIcon: UIImageView!
    @IBOutlet weak var batteryImage: UIImageView!
    
    @IBOutlet var mainView: UIView!
    
    var batteryInfo: BatteryInfo!
    var networkInfo: NetworkInfo!
    var tools: Tools!
    var reach: Reachability!
    var values = DataNetwork()
    
    private var Context: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tools = Tools()
        self.batteryInfo = BatteryInfo()
        self.networkInfo = NetworkInfo()
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.Mon), userInfo: nil, repeats: true)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.runApp))
        self.mainView.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryState), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevel), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
    }
    
    func runApp() {
        extensionContext?.open(URL(string: "BatteryLife://")!, completionHandler: nil)
    }
    
   private func performWidgetUpdate() {
        self.batteryLvl.text = String(self.batteryInfo.BatteryLevel())+" %"
        self.remaining.text = self.batteryInfo.toggleStatus().1
        
        if (self.batteryInfo.toggleStatus().0 != 1) {
            self.chargeIcon.isHidden = false
        }
        else {
            self.chargeIcon.isHidden = true
        }
        
        if (batteryInfo.BatteryLevel() <= 70) {
            self.batteryImage.image = UIImage(named: "battery-mid")
        }
        else if (batteryInfo.BatteryLevel() <= 20) {
            self.batteryImage.image = UIImage(named: "battery-low")
        }
        else {
            self.batteryImage.image = UIImage(named: "battery-full")
        }
        
        
        self.reach = Reachability()
        
        if (self.reach?.isReachableViaWiFi)! {
            self.upLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getWifiData(reset: false).3)+"/s"
            self.downLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getWifiData(reset: false).2)+"/s"
        }else {
            self.upLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getPhoneData(reset: false).3)+"/s"
            self.downLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getPhoneData(reset: false).2)+"/s"
        }
    }
    
    func Mon() {
        if (self.reach?.isReachableViaWiFi)! {
            self.upLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getWifiData(reset: false).3)+"/s"
            self.downLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getWifiData(reset: false).2)+"/s"
        }else {
            self.upLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getPhoneData(reset: false).3)+"/s"
            self.downLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getPhoneData(reset: false).2)+"/s"
        }
        //self.downLoadSpeed.text = self.tools.formatSizeRoundUnits(bytes: self.networkInfo.getWifiData(reset: false).2)+"/s"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.performWidgetUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc private func batteryState() {
        
        if (self.batteryInfo.toggleStatus().0 != 1) {
            self.chargeIcon.isHidden = false
        }
        else {
            self.chargeIcon.isHidden = true
        }
        
        self.remaining.text = self.batteryInfo.toggleStatus().1
        //if (self.batteryInfo.BatteryState().0) {
        //}
    }
    
    @objc private func batteryLevel() {
        
        if (batteryInfo.BatteryLevel() >= 30 && batteryInfo.BatteryLevel() <= 70) {
            self.batteryImage.image = UIImage(named: "battery-mid")
        }
        else if (batteryInfo.BatteryLevel() < 30) {
            self.batteryImage.image = UIImage(named: "battery-low")
        }
        else {
            self.batteryImage.image = UIImage(named: "battery-full")
        }
        
        self.batteryLvl.text = String(batteryInfo.BatteryLevel())+" %"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        self.performWidgetUpdate()
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
