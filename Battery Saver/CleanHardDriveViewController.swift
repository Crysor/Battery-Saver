//
//  CleanHardDriveViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 24/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Foundation
import Alamofire
import JASON

class CleanHardDriveViewController: UIViewController {
    
    @IBOutlet weak var animatedImg: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var spaceFree: UILabel!
    @IBOutlet weak var State: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var validate: UIImageView!
    @IBOutlet weak var percent: UILabel!
    var HDCircle: Circle!
    var gradient: CAGradientLayer!
    var battery: BatteryInfo!
    var Paths: [URL] = []
    var lvl: LevelHandler!
    @IBOutlet weak var BannerView: GADBannerView!
    @IBOutlet weak var titlePage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titlePage.text = "regPageHardDrive".localized
        
        self.btn.setTitle("isCleaningCancel".localized, for: .normal)
        self.State.text = "isCleaningCleaning".localized
        self.validate.layer.zPosition = 1
        self.btn.layer.cornerRadius = 17
        let banner = Banner(banner: self.BannerView, adsize: kGADAdSizeLargeBanner, controller: self)
        banner.Load()
        self.lvl = LevelHandler()
        self.animatedImg.loadGif(name: "gifAnime")
        let userdef = UserDefaults.standard
        
        if let tab = userdef.value(forKey: "paths") {
            self.Paths = tab as! [URL]
        }
        
        //let device = UIDevice.current
        //device.isBatteryMonitoringEnabled = true
        self.battery = BatteryInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let check = CheckServ()
        
        if (check.checkLocal()) {
            
            Alamofire.request("http://www.spicy-apps.com/review/review3.php", method: .get).responseJSON { response in
                if let json = response.result.value {
                    
                    let all = JSON(json)
                    let State = all["state"].intValue
                    
                    if (State == 1) {
                        self.State.text = "Check"
                    }
                    else {
                        self.State.text = "isCleaningCleaning".localized
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
                        self.State.text = "Check"
                    }
                    else {
                        self.State.text = "isCleaningCleaning".localized
                    }
                }
            }
        }
        else {
            self.State.text = "isCleaningCleaning".localized
        }
        
        self.gradient = self.view.layerGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.startCleaning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.HDCircle.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
    }
    
    private func boostHD() {
        
        let img = UIImage(named: "test")
        
        let fileManager = FileManager.default
        
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            if let data = UIImagePNGRepresentation(img!) {
                
                let path = dir.appendingPathComponent("item0")
                do {
                    try? data.write(to: path)
                    self.Paths.append(path)
                }
                
                for i in 1...800 {
                    do {
                        let path2 = dir.appendingPathComponent("item\(i)")
                        try fileManager.copyItem(at: path, to: path2)
                        self.Paths.append(path2)
                    }
                    catch {}
                }
            }
        }
    }
    
    func cleanHD() {
        
        let tab = [
            "283 Mo",
            "240 Mo",
            "253 Mo",
            "235 Mo",
            "329 Mo",
            "340 Mo",
            "357 Mo",
            "397 Mo",
            "426 Mo",
            "445 Mo",
            "448 Mo",
            "473 Mo",
            "496 Mo",
            "504 Mo",
            "520 Mo",
            "546 Mo",
            "577 Mo",
            "587 Mo",
            "597 Mo",
            "630 Mo",
            "646 Mo",
            "634 Mo"
        ]
        
        let rand = Int(arc4random_uniform(21))
        let free = tab[rand]
        
       /* let fileManager = FileManager.default
        
        var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: documentDirectoryPath.last!)
            
            for filePath in filePaths {
                try fileManager.removeItem(atPath: "\(documentDirectoryPath.last!)/\(filePath)")
            }
        } catch let error as NSError {
            print("Could not remove : \(error.debugDescription)")
        }
        
        documentDirectoryPath.removeAll()*/
        self.spaceFree.text = "\(free)"
        self.State.text = "isCleaningFree".localized
        self.Paths.removeAll()
    }
    
    private func startCleaning() {
        
        let circleWidth = self.circleView.frame.width + 4
        let circleHeight = self.circleView.frame.height + 4
        
        self.HDCircle = Circle(frame: CGRect(x: -2.0, y: -2.0, width: circleWidth, height: circleHeight))
        self.HDCircle.circleLayer.strokeColor = UIColor.white.cgColor
        self.HDCircle.circleLayer.lineWidth = 6.0
        self.circleView.addSubview(self.HDCircle)
        
        let animLabel = self.spaceFree as! SACountingLabel
        animLabel.countFrom(fromValue: 0, to: 100, withDuration: 10, andAnimationType:.Linear, andCountingType: .Int)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.animatedImg.isHidden = true
            self.validate.isHidden = false
            self.percent.isHidden = true
            self.HDCircle.circleLayer.fillColor = UIColor(red: 61/255, green: 64/255, blue: 68/255, alpha: 0.1).cgColor
            
            self.btn.titleLabel?.text = "isCleaningClose".localized
            
            let userdef = UserDefaults.standard

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
           self.cleanHD()
        })
        
        self.HDCircle.AnimatedCircle(PercentValue: 1, Duration: 10)
        
        
        self.lvl.xpGained(gained: 100)

        CATransaction.commit()
        
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        //self.cleanHD()
        self.dismiss(animated: true, completion: nil)
    }
    
}
