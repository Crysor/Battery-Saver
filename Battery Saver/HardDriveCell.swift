//
//  HardDriveCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import JASON

class HardDriveCell: UITableViewCell {
    
    @IBOutlet weak var SpaceValue: UILabel!
    @IBOutlet weak var SpacePercent: UILabel!
    var DataMonitor: Timer!
    @IBOutlet weak var hdLabel: UILabel!
    @IBOutlet weak var space: UILabel!
    @IBOutlet weak var clean: UILabel!
    
    
    @IBOutlet weak var theView: UIView!
    var tools: Tools!
    var handler: HardDriveHandler!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tools = Tools()
        self.handler = HardDriveHandler()

        let check = CheckServ()
        
        if (check.checkLocal()) {
            
            Alamofire.request("http://www.spicy-apps.com/review/review3.php", method: .get).responseJSON { response in
                if let json = response.result.value {
                    
                    let all = JSON(json)
                    let State = all["state"].intValue
                    
                    if (State == 1) {
                        self.clean.text = "Check"
                    }
                    else {
                        self.clean.text = "memoryClean".localized
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
                        self.clean.text = "Check"
                    }
                    else {
                        self.clean.text = "memoryClean".localized
                    }
                }
            }
        }
        else {
            self.clean.text = "memoryClean".localized
       }
        
        self.hdLabel.text = "statusListHardDrive".localized
        self.space.text = "statusListSpaceLeft".localized
        
        self.SpaceValue.text = self.tools.formatSizeUnits(bytes: self.handler.deviceRemainingFreeSpaceInBytes())
        self.SpacePercent.text = String(self.handler.deviceRemainingFreeSpaceInPercent())+"%"
        
        let userdef = UserDefaults.standard
        
        if userdef.value(forKey: "tuto") != nil {
            self.theView.mask = nil
        }
        else {
        
        let mask = UIView(frame: CGRect(x: self.theView.frame.origin.x, y: self.theView.frame.origin.y, width: self.theView.frame.size.width, height: self.theView.frame.size.height))
        mask.backgroundColor = UIColor.black
        mask.alpha = 0.2
            if #available(iOS 9.0, *) {
                self.theView.mask = mask
            }
        }
        
        DispatchQueue.main.async {
            self.DataMonitor = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.HardDriveMonitoring), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func HardDriveMonitoring() {

        self.SpaceValue.text = self.tools.formatSizeUnits(bytes: self.handler.deviceRemainingFreeSpaceInBytes())
        self.SpacePercent.text = String(self.handler.deviceRemainingFreeSpaceInPercent())+"%"
    }
}
