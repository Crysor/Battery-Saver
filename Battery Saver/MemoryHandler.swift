//
//  MemoryHandler.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 12/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation

class MemoryHandler {
    
    var tools : Tools!
    
    init() {
        self.tools = Tools()
    }
    
    public func getMemoryPercent() -> Int64 {
        let value: Int64 = self.tools.getMegabytesUsed()
        
        let percent: Int64 = (value * 100) / 2147483648
        
        if (percent >= 97){
            return 97
        }else {
            return percent
        }
    }
    
    public func getMemoryFreeSpace() -> String {
        let value: Int64 = self.tools.getMegabytesUsed()
        let free: Int64 = 2147483648 - value
        
        round(Double(free))
        
        if (free <= 0) {
            return self.tools.formatSizeUnits(bytes: 38797312)
        }
        
        return self.tools.formatSizeUnits(bytes: free)
    }
}
