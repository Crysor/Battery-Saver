//
//  DataTools.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

class Tools {
    
    var MemoryMonitor: Timer!
    static var flag: Int = 0
    static var index: Int = 17
    
    init(){
        
    }
    
    public func memIndex() {
        Tools.flag += 1
        if (Tools.flag == 6){
            if (Tools.index <= 75) {
                Tools.index += 1
            }
            Tools.flag = 0
        }
    }
    
    public func cleanMem() {
        Tools.flag = 0
        Tools.index = 8
    }
    
    // TODO faire un truc avec ca
    public func saveLastOpening() {
        
        let def = UserDefaults.standard
        
        def.set(Date(), forKey: "last")
        def.synchronize()
    }
    
    public func formatSizeMega(bytes: Int64) -> Double {
        return Double(bytes) / Double(1048576)
    }
    
    public func formatSizeKo(bytes: Int64) -> Double {
        return Double(bytes) / Double(1024)
    }
    
    public func formatSizeUnits(bytes: Int64) -> Double {
        
        if (bytes >= 1000000000) {
            return Double(bytes) / Double(1073741824)
        }
        else if (bytes >= 1000000) {
           return Double(bytes) / Double(1048576)
        }
        else if (bytes >= 1000) {
            return  Double(bytes) /  Double(1024)
        }
        else if (bytes > 1) {
            return Double(bytes)
        }
        else if (bytes == 1) {
           return Double(bytes)
        }
        else {
            return 0
        }
    }
    
    public func formatSizeRoundUnits(bytes: Int64) -> String {
        
        var size: String!
        
        if (bytes >= 1000000000) {
            size = "\(bytes / 1073741824) GB"
        }
        else if (bytes >= 1000000) {
            size = "\(bytes / 1048576) MB" //String(format: "%.2f", bytes / 1048576)+" MB"
        }
        else if (bytes >= 1000) {
            size = "\(bytes / 1024) kB"
        }
        else if (bytes > 1) {
            size = "\(bytes) B"
        }
        else if (bytes == 1) {
            size = "\(bytes) B"
        }
        else {
            size = "0 B"
        }
        
        return size
    }
    
    public func formatSizeUnits(bytes: Int64) -> String {
        
        var size: String!
        
        if (bytes >= 1000000000) {
            let val = Double(bytes) / Double(1073741824)
            
            if (val >= 10) {
                size = "\(Int(val)) GB"
            }
            else {
                
                if (val < 1){
                   size = "\(Int64(val * 1000)) MB"
                }
                else {
                    size = String(format: "%.2f", Double(val))+" GB"
                }
            }
        }
        else if (bytes >= 1000000) {
            size = "\(bytes / 1048576) MB"
        }
        else if (bytes >= 1000) {
            size = "\(bytes / 1024) KB"
        }
        else if (bytes > 1) {
            size = "\(bytes) B"
        }
        else if (bytes == 1) {
            size = "\(bytes) B"
        }
        else {
            size = "0 B"
        }

        return size
    }
    
    private func mach_task_self() -> task_t {
        return mach_task_self_
    }
    
    public func getMegabytesUsed() -> Int64 {
        
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self(),
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return 0
        }
        return Int64(info.resident_size) * Int64(Tools.index)
    }
    
    func animateTable(table: UITableView) {
       table.reloadData()
        
        let cells = table.visibleCells
        let tableHeight: CGFloat = table.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
           
            cell.awakeFromNib()

            UIView.animate(withDuration: 0.8, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.transitionCurlDown, animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
}
