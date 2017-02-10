//
//  SystemeViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 26/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit

class SystemeViewController: UITableViewController {
    
    var deviceSec = [CellSection]()
    var networkSec = [CellSection]()
    var hardware = [CellSection]()
    var tool: Tools!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = "regPageSystem".localized

        self.tool = Tools()
        self.loadInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return self.deviceSec.count
        }
        if (section == 1) {
            return self.networkSec.count
        }
        if (section == 2) {
            return self.hardware.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "device_detail".localized
        case 1:
            return "network_info".localized
        case 2:
            return "hardware_spec".localized
        default:
            break
        }
        
        return ""
    }
    
    private func loadInformation() {
        
        
        let device = DeviceInfo()
        
        self.deviceSec.append(CellSection(info: "device_name".localized, data: device.Name))
        self.deviceSec.append(CellSection(info: "version".localized, data: device.Version))
        self.deviceSec.append(CellSection(info: "model".localized, data: device.Model))
        
        
        let networkInfo = NetworkInfo()

        self.networkSec.append(CellSection(info: "ip_addr".localized, data: networkInfo.getIpAddress()))
        self.networkSec.append(CellSection(info: "carrier_name".localized, data: networkInfo.CarrierName))
        self.networkSec.append(CellSection(info: "data_rcv".localized, data: self.tool.formatSizeUnits(bytes: networkInfo.getData().0)))
        self.networkSec.append(CellSection(info: "data_sent".localized, data: self.tool.formatSizeUnits(bytes: networkInfo.getData().1)))

        
        let hardwareInfo = HardwareSpecification()
        
        if let cpu = hardwareInfo.HardwareDetails["CPU"] {
            self.hardware.append(CellSection(info: "cpu".localized, data: cpu))
        }
        if let weight = hardwareInfo.HardwareDetails["weight"] {
            self.hardware.append(CellSection(info: "weight".localized, data: weight))
        }
        if let bat = hardwareInfo.HardwareDetails["battery"] {
            self.hardware.append(CellSection(info: "battery".localized, data: bat))
        }
        if let screen = hardwareInfo.HardwareDetails["screen_size"] {
            self.hardware.append(CellSection(info: "screen_size".localized, data: screen))
        }
        if let size = hardwareInfo.HardwareDetails["size"] {
            self.hardware.append(CellSection(info: "size".localized, data: size))
        }
        if let reso = hardwareInfo.HardwareDetails["resolution"] {
            self.hardware.append(CellSection(info: "reso".localized, data: reso))
        }
        if let cam = hardwareInfo.HardwareDetails["cam"] {
            self.hardware.append(CellSection(info: "cam_back".localized, data: cam))
        }
        if let cam_front = hardwareInfo.HardwareDetails["cam_front"] {
            self.hardware.append(CellSection(info: "cam_front".localized, data: cam_front))
        }
    }
      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cellIdentifier = "SystemeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SystemeCellViewController
        if (indexPath.section == 0) {
            
            let device = self.deviceSec[indexPath.row]
            
            cell.Info.text = device.LabelInfo
            cell.data.text = device.LabelData
        }
        if (indexPath.section == 1) {
            let network = self.networkSec[indexPath.row]
            
            cell.Info.text = network.LabelInfo
            cell.data.text = network.LabelData
        }
        if (indexPath.section == 2) {
            let hardware = self.hardware[indexPath.row]
            
            cell.Info.text = hardware.LabelInfo
            cell.data.text = hardware.LabelData
        }
        
        return cell
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
