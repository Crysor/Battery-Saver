//
//  HardDriveHandler.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation

class HardDriveHandler {
    
    var tools: Tools!
    
    init(){
        self.tools = Tools()
    }
    
    public func deviceRemainingFreeSpaceInBytes() -> Int64 {
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.int64Value
            }
        }
        return -1
    }
    
    public func deviceRemainingFreeSpaceInPercent() -> Int64 {
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
            guard let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber else { return -1 }
            guard let Size = systemAttributes[FileAttributeKey.systemSize] as? NSNumber else { return -1 }
            
            let total: Int64 = freeSize.int64Value + Size.int64Value
            
            let percent = (Size.int64Value * 100) / total
            return percent
        }
        
        return -1
    }
}
