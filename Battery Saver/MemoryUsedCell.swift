//
//  MemoryUsedCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import JASON

class MemoryUsedCell: UITableViewCell {
    
    @IBOutlet weak var percentUsed: UILabel!
    @IBOutlet weak var ValueAvailable: UILabel!
    @IBOutlet weak var theView: UIView!
    
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var memuse: UILabel!
    @IBOutlet weak var boost: UILabel!
    
    var MemHandler: MemoryHandler!
    var MemoryMonitor: Timer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.MemHandler = MemoryHandler()
        
        let check = CheckServ()
        
        if (check.checkLocal()) {
            
            Alamofire.request("http://www.spicy-apps.com/review/review3.php", method: .get).responseJSON { response in
                if let json = response.result.value {
                    
                    let all = JSON(json)
                    let State = all["state"].intValue
                    
                    if (State == 1) {
                        self.boost.text = "Check"
                    }
                    else {
                        self.boost.text = "statusListBoost".localized
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
                        self.boost.text = "Check"
                    }
                    else {
                        self.boost.text = "statusListBoost".localized
                    }
                }
            }
        }
        else {
            self.boost.text = "statusListBoost".localized
        }
        self.memuse.text =  "statusListMemoryUsed".localized
        self.available.text = "statusListAvailable".localized
        
        self.percentUsed.text = String(self.MemHandler.getMemoryPercent())+"%"
        self.ValueAvailable.text = self.MemHandler.getMemoryFreeSpace()
       
        DispatchQueue.main.async {
            self.MemoryMonitor = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.MemoryMonitoring), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func MemoryMonitoring() {
        
        self.percentUsed.text = String(self.MemHandler.getMemoryPercent())+"%"
        self.ValueAvailable.text = self.MemHandler.getMemoryFreeSpace()
    }
}
