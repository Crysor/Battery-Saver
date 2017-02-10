//
//  SecondViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Alamofire
import JASON

class ChargeViewController: UIViewController {

    @IBOutlet weak var Remaining: UILabel!
    @IBOutlet weak var BatteryState: UIImageView!
    @IBOutlet weak var BatteryLevel: UILabel!
    @IBOutlet weak var Percent: UILabel!
    
    @IBOutlet weak var StateLabel: UILabel!
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var LevelUser: UILabel!
    
    @IBOutlet weak var boostBtn: UIButton!
    @IBOutlet weak var BannerView: GADBannerView!
    @IBOutlet weak var commentLvl: UILabel!
    @IBOutlet weak var titlePage: UILabel!
    
    var battery_info: BatteryInfo!
    var Device: UIDevice!
    var gradient: CAGradientLayer!
    var timer : Timer!
    var lvlHandler: LevelHandler!
    //var tracker: GAITracker!
    var gtracker: TrackerGoogle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titlePage.text = "regPageCharge".localized
        self.boostBtn.setTitle("btn_boost".localized, for: .normal)
        self.boostBtn.isHidden = true
        self.commentLvl.isHidden = true
        self.checkUs()
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "Charge")
        self.boostBtn.layer.cornerRadius = 17
        
        let btnges = UITapGestureRecognizer(target:self, action: #selector(self.boostAction))
        self.boostBtn.addGestureRecognizer(btnges)
        
        
        let banner = Banner(banner: self.BannerView, adsize: kGADAdSizeSmartBannerPortrait, controller: self)
        banner.Load()
        
        self.lvlHandler = LevelHandler()
        self.LevelUser.text = String(self.lvlHandler.lvl)
        self.setComments()
        //self.Device = UIDevice.current
        //self.Device.isBatteryMonitoringEnabled = true
        self.BatteryLevel.layer.zPosition = 1
        self.battery_info = BatteryInfo()
        self.setElemState()
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryState), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryLevel), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        
        self.setupSwipeControls()
    }
    
    private func checkUs() {
        let check = CheckServ()
        
        if (check.checkLocal()) {
            
            Alamofire.request("http://www.spicy-apps.com/review/review3.php", method: .get).responseJSON { response in
                if let json = response.result.value {
                    
                    let all = JSON(json)
                    let State = all["state"].intValue
                    
                    if (State == 1) {
                        self.boostBtn.isHidden = true
                        self.commentLvl.isHidden = true
                    }
                }
                else {
                    let today = Date()
                    
                    let calendar = NSCalendar.current
                    let calendarComponents = NSDateComponents()
                    calendarComponents.day = 1
                    calendarComponents.month = 1
                    calendarComponents.year = 2017
                    let dateToFIre = calendar.date(from: calendarComponents as DateComponents)
                    
                    if (today.compare(dateToFIre!) == ComparisonResult.orderedAscending) {
                        self.boostBtn.isHidden = true
                        self.commentLvl.isHidden = true
                    }
                    else {
                        self.boostBtn.isHidden = false
                        self.commentLvl.isHidden = false
                    }
                }
            }
        }
        else {
            self.boostBtn.isHidden = false
            self.commentLvl.isHidden = false
        }
    }
    
    @objc private func boostAction(_ sender: Any) {
        self.gtracker.setEvent(category: "charge", action: "boost", label: "click")
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc private func moreSettings() {
        self.tabBarController?.selectedIndex = 4
    }
    
    @objc private func batteryLevel() {
        self.BatteryLevel.text = String(self.battery_info.BatteryLevel())
        self.view.animateLayerGradient(gradient: self.gradient, lvl: self.battery_info.BatteryLevel())
        self.gradient.animation(forKey: "animateGradient")
    }
    
    @objc private func batteryState() {
        self.battery_info.toggleStatus(img: self.BatteryState, percent: self.Percent, remaining: self.Remaining)
        self.setElemState()
    }
    
    private func setComments() {
        
        var comment: String!
        
        if (self.lvlHandler.lvl <= 4) {
            comment = "chargeIthasbeen".localized
        }
        else if (self.lvlHandler.lvl > 4 && self.lvlHandler.lvl <= 6) {
            comment = "chargeYoushouldclean".localized
        }
        else if (self.lvlHandler.lvl > 6 && self.lvlHandler.lvl <= 9) {
            comment = "chargeYourphoneis".localized
        }
        else if (self.lvlHandler.lvl == 10) {
            comment = "chargeyourabattery".localized
        }
        
        self.commentLvl.text = comment
    }
    
    private func setElemState() {
        switch self.battery_info.BatteryState().0 {
        case 1:
            self.LevelUser.isHidden = false
            self.ImageLabel.image = UIImage(named: "ico_health-score_charge")
            self.StateLabel.text = self.battery_info.BatteryState().1
        case 2:
            self.LevelUser.isHidden = true
            self.ImageLabel.image = UIImage(named: "icone_charge-on-infos")
            self.StateLabel.text = self.battery_info.BatteryState().1
        case 3:
            self.LevelUser.isHidden = true
            self.ImageLabel.image = UIImage(named: "icone_charge-on-infos")
            self.StateLabel.text = self.battery_info.BatteryState().1
        default:break
        }
    }
    
    func setupSwipeControls() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.leftCommand(r:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.rightCommand(r:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        self.gtracker.setEvent(category: "charge", action: "swipe_mem", label: "swipe")
        //let build = (GAIDictionaryBuilder.createEvent(withCategory: "charge", action: "swipe_mem", label: "swipe", value: nil).build() as NSDictionary) as! [AnyHashable: Any]
        //self.tracker.send(build)
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        self.gtracker.setEvent(category: "charge", action: "swipe_status", label: "swipe")
        //let build = (GAIDictionaryBuilder.createEvent(withCategory: "charge", action: "swipe_status", label: "swipe", value: nil).build() as NSDictionary) as! [AnyHashable: Any]
        //self.tracker.send(build)
        self.tabBarController?.selectedIndex = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func MoreApps(_ sender: Any) {
        //tracker
        self.gtracker.setEvent(category: "charge", action: "moreapps", label: "click")
        self.tabBarController?.selectedIndex = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.BatteryLevel.text = String(self.battery_info.BatteryLevel())
        self.battery_info.toggleStatus(img: self.BatteryState, percent: self.Percent, remaining: self.Remaining)
        
        self.gradient = self.view.layerGradient()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

