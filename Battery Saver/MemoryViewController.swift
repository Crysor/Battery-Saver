//
//  MemoryViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON

class MemoryViewController: UIViewController {
    
    var StateMonitor : Timer!
    
    @IBOutlet weak var HdPartView: UIView!
    @IBOutlet weak var MemoryPartView: UIView!
    
    @IBOutlet weak var HdCircleView: UIView!
    @IBOutlet weak var MemoryCircleView: UIView!
    @IBOutlet weak var HDLabel: UILabel!
    @IBOutlet weak var MemLabel: UILabel!
    @IBOutlet weak var MemSpaceLeft: UILabel!
    @IBOutlet weak var HDSpaceLeft: UILabel!
    @IBOutlet weak var cleanBtn: UIButton!
    @IBOutlet weak var boostBtn: UIButton!
    @IBOutlet weak var tutoHand: UIImageView!
    @IBOutlet weak var tutoLabel: UILabel!
    
    @IBOutlet weak var memPartTitle: UILabel!
    @IBOutlet weak var hdPartTitle: UILabel!
    @IBOutlet weak var memLeftLabel: UILabel!
    @IBOutlet weak var spaceLeftLabel: UILabel!
    
    @IBOutlet weak var titlePage: UILabel!
    
    var tutoRun: Bool!
    
    private struct colors {
        let green =  UIColor(red: 105/255, green: 209/255, blue: 123/255, alpha: 1).cgColor
        let red = UIColor(red: 245/255, green: 80/255, blue: 58/255, alpha: 1).cgColor
        let orange = UIColor(red: 244/255, green: 136/255, blue: 78/255, alpha: 1).cgColor
    }
    
    var HDCircle: Circle!
    var MemoryCircle: Circle!
    var HDinfo: HardDriveHandler!
    var Meminfo: MemoryHandler!
    var tools: Tools!
    var battery: BatteryInfo!
    var gradient: CAGradientLayer!
    var gtracker: TrackerGoogle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boostBtn.setTitle("btn_boost".localized, for: .normal)
        self.cleanBtn.setTitle("memoryClean".localized, for: .normal)
        self.boostBtn.isHidden = true
        self.cleanBtn.isHidden = true
        self.checkUs()

        self.boostBtn.setTitle("btn_boost".localized, for: .normal)
        self.cleanBtn.setTitle("memoryClean".localized, for: .normal)
        
        self.tutoLabel.text = "tutoappuie".localized
        self.titlePage.text = "regPageMemory".localized
        
        self.memPartTitle.text = "memoryMemory".localized
        self.hdPartTitle.text = "memoryHardDrive".localized
        
        
        self.memLeftLabel.text = "memoryMemoryLeft".localized
        self.spaceLeftLabel.text = "memorySpaceLeft".localized
        
        self.checkUs()
        
        let userdef = UserDefaults.standard
        
        if (userdef.value(forKey: "tuto") != nil) {
            self.tutoRun = false
        }
        else {
            self.tutoRun = true
        }
        self.MemoryPartView.layer.zPosition = 1
        
        self.boostBtn.layer.cornerRadius = 17
        self.cleanBtn.layer.cornerRadius = 17
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "Memory")

        //let device = UIDevice.current
        //device.isBatteryMonitoringEnabled = true
        self.battery = BatteryInfo()
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
                        self.cleanBtn.isHidden = true
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
                        self.cleanBtn.isHidden = true

                    }
                    else {
                        self.boostBtn.isHidden = false
                        self.cleanBtn.isHidden = false
                    }
                }
            }
        }
        else {
            self.boostBtn.isHidden = false
            self.cleanBtn.isHidden = false
        }
    }
    
    @objc private func tutomem() {
        self.performSegue(withIdentifier: "cleanmem", sender: nil)
    }
    
    @objc private func moreSettings() {
        self.tabBarController?.selectedIndex = 4
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
        if (self.tutoRun == true) {
            return
        }
        self.gtracker.setEvent(category: "memory", action: "swipe_data", label: "swipe")
        self.tabBarController?.selectedIndex = 3
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        if (self.tutoRun == true) {
            return
        }
        self.gtracker.setEvent(category: "memory", action: "swipe_charge", label: "swipe")
        self.tabBarController?.selectedIndex = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let check = CheckServ()
        
        if (check.checkLocal() == false) {
            let userdef = UserDefaults.standard
        
            if (userdef.value(forKey: "tuto") != nil) {
                self.tutoRun = false
                self.tutoHand.isHidden = true
                self.tutoLabel.isHidden = true
            
            
                self.tabBarController?.tabBar.mask = nil
                self.tabBarController?.tabBar.isUserInteractionEnabled = true

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
                self.tutoLabel.layer.zPosition = 2
                self.tutoHand.layer.zPosition = 2
            
                let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                v.backgroundColor = UIColor.black
                v.alpha = 0.2
                self.tabBarController?.tabBar.isUserInteractionEnabled = false
                guard ((self.tabBarController?.tabBar.mask = v) != nil) else {
                    return
                }
            
                let mask = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                mask.backgroundColor = UIColor.black
                mask.layer.zPosition = 0
                mask.alpha = 0.8
                mask.tag = 142
                let g = UITapGestureRecognizer(target:self, action: #selector(self.tutomem))
                mask.addGestureRecognizer(g)
                self.view.addSubview(mask)
            
                let oldpos = self.tutoHand.center.y
                UIView.animate(withDuration: 1, delay: 0.3, options: [.curveLinear, .repeat, .autoreverse], animations: {
                    self.tutoHand.center.y -= 20
                    if (self.tutoHand.center.y == oldpos-20) {
                        self.tutoHand.center.y = oldpos
                    }
                }, completion: nil)
            }
        }
        else {
            let userdef = UserDefaults.standard
            
            userdef.set(0, forKey: "tuto")
            userdef.synchronize()
            self.tabBarController?.tabBar.mask = nil//UIView()
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
        /*if (self.ratePopUp().1 == 1) {
            self.present(self.ratePopUp().0, animated: true, completion: nil)
        }*/
        
        self.tools = Tools()
        self.HDinfo = HardDriveHandler()
        self.Meminfo = MemoryHandler()
        
        self.HDLabel.text = String(self.HDinfo.deviceRemainingFreeSpaceInPercent())+"%"
        self.HDSpaceLeft.text = String(self.tools.formatSizeUnits(bytes: self.HDinfo.deviceRemainingFreeSpaceInBytes()))
        
        self.MemLabel.text = String(self.Meminfo.getMemoryPercent())+"%"
        self.MemSpaceLeft.text = self.Meminfo.getMemoryFreeSpace()
        
        self.addCircleView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.HDCircle.removeFromSuperview()
        self.MemoryCircle.removeFromSuperview()
    }
    
    private func addCircleView() {
        
        let color = colors()
        
        let circleWidth = CGFloat(100)
        let circleHeight = circleWidth
        
        // Create a new CircleView
        self.HDCircle = Circle(frame: CGRect(x: 0, y: 0, width: circleWidth, height: circleHeight))
        let defCircle = Circle(frame: CGRect(x: 0, y: 0, width: circleWidth, height: circleHeight))
        defCircle.circleLayer.strokeColor = UIColor.init(red: 146/255, green: 148/255, blue: 153/255, alpha: 0.2).cgColor
        defCircle.circleLayer.lineWidth = 6.0
        
        if (self.HDinfo.deviceRemainingFreeSpaceInPercent() >= 75) {
            self.HDCircle.circleLayer.strokeColor = color.red
        }
        else if (self.HDinfo.deviceRemainingFreeSpaceInPercent() < 75 && self.HDinfo.deviceRemainingFreeSpaceInPercent() > 30) {
            self.HDCircle.circleLayer.strokeColor = color.orange
        }
        else if (self.HDinfo.deviceRemainingFreeSpaceInPercent() <= 30) {
            self.HDCircle.circleLayer.strokeColor = color.green
        }
        
        self.HDCircle.circleLayer.lineWidth = 6.0
        self.HDCircle.addSubview(defCircle)
        self.HdPartView.addSubview(self.HdCircleView)
        self.HdCircleView.addSubview(self.HDCircle)
        
        self.MemoryCircle = Circle(frame: CGRect(x: 0, y: 0, width: circleWidth, height: circleHeight))
        
        if (self.Meminfo.getMemoryPercent() >= 75) {
            self.MemoryCircle.circleLayer.strokeColor = color.red
        }
        else if (self.Meminfo.getMemoryPercent() < 75 && self.Meminfo.getMemoryPercent() > 30) {
            self.MemoryCircle.circleLayer.strokeColor = color.orange
        }
        else if (self.Meminfo.getMemoryPercent() <= 30) {
            self.MemoryCircle.circleLayer.strokeColor = color.green
        }
        
        //self.MemoryCircle.circleLayer.strokeColor = UIColor(red: 105/255, green: 209/255, blue: 123/255, alpha: 1).cgColor
        self.MemoryCircle.circleLayer.lineWidth = 6.0
        let defCircleMem = Circle(frame: CGRect(x: 0, y: 0, width: circleWidth, height: circleHeight))
        defCircleMem.circleLayer.strokeColor = UIColor.init(red: 146/255, green: 148/255, blue: 153/255, alpha: 0.2).cgColor
        defCircleMem.circleLayer.lineWidth = 6.0

        self.MemoryCircle.addSubview(defCircleMem)
        self.MemoryPartView.addSubview(self.MemoryCircleView)
        self.MemoryCircleView.addSubview(self.MemoryCircle)
        

        self.HDCircle.AnimatedCircle(PercentValue:  CGFloat(self.HDinfo.deviceRemainingFreeSpaceInPercent())/100, Duration: 1)
        self.MemoryCircle.AnimatedCircle(PercentValue: CGFloat(self.Meminfo.getMemoryPercent())/100, Duration: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if (self.ratePopUp().1 == 1) {
            self.present(self.ratePopUp().0, animated: true, completion: nil)
        }
        
        self.gradient = self.view.layerGradient()
        
        let monState = MonitorManager(target: self, sel: #selector(self.MonitoringState))
        self.StateMonitor = monState.MonitorHandler()
    }
    
    //Monitor
    @objc private func MonitoringState() {
        self.view.animateLayerGradient(gradient: self.gradient, lvl: self.battery.BatteryLevel())
        self.gradient.animation(forKey: "animateGradient")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.StateMonitor.invalidate()
        self.StateMonitor = nil
    }
    
    @IBAction func CleanHardrive(_ sender: AnyObject) {
        
        let message = "disclaimerText".localized
        let alert =  UIAlertController(title: "disclaimerTitle".localized, message: message, preferredStyle: .alert)
        let clean = UIAlertAction(title: "memoryClean".localized, style: .default, handler: { Void in
            //let build = (GAIDictionaryBuilder.createEvent(withCategory: "memory", action: "clean", label: "click", value: nil).build() as NSDictionary) as! [AnyHashable: Any]
            //self.tracker.send(build)
            self.gtracker.setEvent(category: "memory", action: "clean", label: "click")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "HDclean")
            self.present(controller, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "leaveCancel".localized, style: .destructive, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(clean)

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cleanHD(_ sender: Any) {
       
    }
    
    @IBAction func MoreApps(_ sender: Any) {
        //tracker
        self.gtracker.setEvent(category: "memory", action: "moreapps", label: "click")
        self.tabBarController?.selectedIndex = 4
    }
    
    @IBAction func BoostMemory(_ sender: AnyObject) {
        
        let userdef = UserDefaults.standard
        userdef.set(self.tools.getMegabytesUsed(), forKey: "oldmem")
        userdef.synchronize()

        self.gtracker.setEvent(category: "memory", action: "boost", label: "click")
        //let build = (GAIDictionaryBuilder.createEvent(withCategory: "memory", action: "boost", label: "click", value: nil).build() as NSDictionary) as! [AnyHashable: Any]
        //self.tracker.send(build)
    }
}
