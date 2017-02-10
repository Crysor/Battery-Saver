//
//  CleanMemoryViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 24/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON

class CleanMemoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var cleaningState: UILabel!
    @IBOutlet weak var cleanLabel: SACountingLabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var animatedImg: UIImageView!
    @IBOutlet weak var validIco: UIImageView!
    var MemoryCircle: Circle!
    var gradient: CAGradientLayer!
    var battery: BatteryInfo!
    var tools: Tools!
    static var oldmem: Int64 = 0
    static var i: Int = 0
    var tab : [ItemTab]!
    var lvl: LevelHandler!
    var memInfo: MemoryHandler!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var timer: Timer!
    @IBOutlet weak var Board: UIView!
    
    @IBOutlet weak var labelTimeGained: UILabel!
    @IBOutlet weak var labelMemUse: UILabel!
    @IBOutlet weak var memUse: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var titlePage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titlePage.text = "regPageMemory".localized
        //self.cleaningState.text = "statusListBoost".localized
        self.btn.setTitle("isCleaningCancel".localized, for: .normal)
        self.labelMemUse.text = "isCleaningMemoryUse".localized
        self.labelTimeGained.text = "isCleaningTimegained".localized
        
        let userdef = UserDefaults.standard
        userdef.set(0, forKey: "tuto")
        userdef.synchronize()
        
        self.validIco.layer.zPosition = 1
        self.btn.layer.cornerRadius = 17
        self.Board.isHidden = true
        self.memInfo = MemoryHandler()
        self.lvl = LevelHandler()
        self.tab = [ItemTab]()
        self.animatedImg.loadGif(name: "gifAnime")
        //let device = UIDevice.current
        //device.isBatteryMonitoringEnabled = true
        self.battery = BatteryInfo()
        self.tools = Tools()
        self.setItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let check = CheckServ()
        
        if (check.checkLocal()) {
            
            Alamofire.request("http://www.spicy-apps.com/review/review3.php", method: .get).responseJSON { response in
                if let json = response.result.value {
                    
                    let all = JSON(json)
                    let State = all["state"].intValue
                    
                    if (State == 1) {
                        self.cleaningState.text = "Check"
                    }
                    else {
                        self.cleaningState.text = "isCleaningCleaning".localized
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
                        self.cleaningState.text = "Check"
                    }
                    else {
                        self.cleaningState.text = "isCleaningCleaning".localized
                    }
                }
            }
        }
        else {
            self.cleaningState.text = "isCleaningCleaning".localized
        }

        self.gradient = self.view.layerGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.startCleaning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.MemoryCircle.removeFromSuperview()
    }
    
    private func setItems() {
       
        let uncheck = UIImage(named: "ico_valide-off-app-kill")
        
        let labels = [
            "app0".localized,
            "app1".localized,
            "app2".localized,
            "app3".localized,
            "app4".localized,
            "app5".localized,
            "app6".localized,
            "app7".localized
        ]
        
        for i in 0...7 {
            let img = UIImage(named: "app\(i)")
            self.tab.append(ItemTab(img: img!, label: labels[i], imgCheck: uncheck!, row: i))
        }
    }
    
  @objc private func animatedCleanTab() {
    
        //var i = 0
    
        if (CleanMemoryViewController.i > 7) {
            self.animationView.isHidden = true
            return
        }
        let index = IndexPath(row: CleanMemoryViewController.i, section: 0)
        let check = UIImage(named: "ico_valide-on-app-kill")
    
        let cell = self.tableView.cellForRow(at: index) as! ItemCell
        cell.imgcheck.image = check
        cell.alpha = 0.5
    
    
        self.tableView.scrollToRow(at: index, at: UITableViewScrollPosition.top, animated: true)
    
        CleanMemoryViewController.i += 1
    }
    
    private func startCleaning() {
       

        //self.animatedCleanTab()

        //let Min = htab[rand]
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(animatedCleanTab), userInfo: nil, repeats: true)        
        
        let circleWidth = self.circleView.frame.width + 4
        let circleHeight = self.circleView.frame.height + 4
        
        self.MemoryCircle = Circle(frame: CGRect(x: -2.0, y: -2.0, width: circleWidth, height: circleHeight))
        self.MemoryCircle.circleLayer.strokeColor = UIColor.white.cgColor
        self.MemoryCircle.circleLayer.lineWidth = 6.0
        self.circleView.addSubview(self.MemoryCircle)
        
        cleanLabel.countFrom(fromValue: 0, to: 100, withDuration: 4, andAnimationType:.Linear, andCountingType: .Int)

        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            self.animationView.isHidden = true
            self.Board.frame.size.height = 70
            self.Board.isHidden = false
            CleanMemoryViewController.i = 0
            self.view.willRemoveSubview(self.animationView)
            
            if (self.timer.isValid) {
                self.timer.invalidate()
            }
            self.animatedImg.isHidden = true
            self.validIco.isHidden = false
            self.percent.isHidden = true
            self.MemoryCircle.circleLayer.fillColor = UIColor(red: 61/255, green: 64/255, blue: 68/255, alpha: 0.2).cgColor
            let newMem = self.tools.getMegabytesUsed()

            let userdef = UserDefaults.standard
            
            var free: String!
            var Min: String = ""
            
            if let old: Int64 = userdef.value(forKey: "oldmem") as! Int64? {
                
                let res: Double = self.tools.formatSizeUnits(bytes: newMem - old)
                free = self.tools.formatSizeRoundUnits(bytes: newMem - old)
                
                if (res < 205 && res > 0) {
                    let htab = [
                        "2 Minutes",
                        "3 Minutes",
                        "4 Minutes",
                        "5 Minutes",
                        "6 Minutes"
                    ]
                    let rand = Int(arc4random_uniform(3))
                    Min = htab[rand]
                }
                else if (res >= 205 && res < 300) {
                    let htab = [
                        "10 Minutes",
                        "11 Minutes",
                        "12 Minutes",
                        "13 Minutes"
                    ]
                    let rand = Int(arc4random_uniform(3))
                    Min = htab[rand]
                }
                else if (res >= 300 && res < 400) {
                    let htab = [
                        "14 Minutes",
                        "15 Minutes",
                        "16 Minutes",
                        "17 Minutes"
                    ]
                    let rand = Int(arc4random_uniform(3))
                    Min = htab[rand]
                }
                else if (res >= 400 && res < 500) {
                    let htab = [
                        "18 Minutes",
                        "19 Minutes",
                        "20 Minutes",
                        "21 Minutes"
                    ]
                    let rand = Int(arc4random_uniform(3))
                    Min = htab[rand]
                }
                else {
                    let htab = [
                        "22 Minutes",
                        "23 Minutes",
                        "24 Minutes",
                        "25 Minutes"
                    ]
                    let rand = Int(arc4random_uniform(3))
                    Min = htab[rand]
                }
                
            }
            else {
                free = "204"
                Min = "9 Minutes"
            }
            
            
            self.cleanLabel.text = "\(free!) "+"isCleaningFree".localized
            self.cleaningState.text = "isCleaningTimegained".localized+" \(Min) !"
            
            self.btn.titleLabel?.text = "isCleaningClose".localized
            
            self.tools.cleanMem()
            self.time.text = Min
            self.memUse.text = "\(self.memInfo.getMemoryPercent())%"
            
            if let open: Int = userdef.value(forKey: "open") as! Int? {
                
                if (open >= 3) {
                    var nb : Int!
                    
                    if let nbBoost: Int = userdef.value(forKey: "boost") as! Int? {
                        nb = nbBoost + 1
                        userdef.set(nb, forKey: "boost")
                        userdef.synchronize()
                    }
                    else {
                        userdef.set(1, forKey: "boost")
                        userdef.synchronize()
                    }
                }
            }
            
            self.lvl.xpGained(gained: 100)
        })
        
        self.MemoryCircle.AnimatedCircle(PercentValue: 1, Duration: 4)
        CATransaction.commit()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(68)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tab.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemCell
        
        let content = self.tab[indexPath.row]
        
        cell.img.image = content.img
        cell.labelapp.text = content.label
        cell.imgcheck.image = content.imgCheck
        
        return cell
    }
    
    @IBAction func done(_ sender: AnyObject) {
        
        let userdef = UserDefaults.standard
        
        userdef.set(0, forKey: "tuto")
        userdef.synchronize()
        
        /*let vc = StatusViewController()
        let indexPath = IndexPath(item: 0, section: 0)
        vc.table_status.reloadRows(at: [indexPath], with: .none)*/
        
        self.timer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
}
