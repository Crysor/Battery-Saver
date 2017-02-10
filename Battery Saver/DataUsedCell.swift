//
//  DataUsedCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation

class DataUsedCell: UITableViewCell {
    
    @IBOutlet weak var NetworkData: UILabel!
    @IBOutlet weak var DataInfo: UILabel!
    var DataMonitor: Timer!
    var networkInfo: NetworkInfo!
    var tools: Tools!
    var UserDef: UserDefaults!
    var todayStr: String!
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var detail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.theView.layer.zPosition = 0

        self.tools = Tools()
        self.networkInfo = NetworkInfo()
        
        self.detail.text = "statusListDetails".localized
        self.NetworkData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getData().0)
        self.DataInfo.text = "statusListPhoneDataUsed".localized//self.networkInfo.getData().4
        
        let userdef = UserDefaults.standard
        
        if userdef.value(forKey: "tuto") != nil {
            self.theView.mask = nil
        }
        else {
        
            let mask = UIView(frame: CGRect(x: self.theView.frame.origin.x, y: self.theView.frame.origin.y, width: self.theView.frame.size.width, height: self.theView.frame.size.height))
            mask.backgroundColor = UIColor.black
            mask.layer.zPosition = 1
            mask.alpha = 0.2
            if #available(iOS 9.0, *) {
                self.theView.mask = mask
            }
        }
        
        DispatchQueue.main.async {
            self.DataMonitor = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.DataMonitoring), userInfo: nil, repeats: true)
        }

    }
    
    @objc private func DataMonitoring() {
        self.NetworkData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getData().0)
        //self.DataInfo.text = //self.networkInfo.getData().4
    }

}
