//
//  Level.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 27/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation

class LevelHandler {
    
    var lvlMax: Int!
    var Totalxp: Int!
    var currentXp: Int
    var lvl: Int
    
    init() {
        
        self.Totalxp = 1000
        self.lvlMax = 10
        
        let usrdef = UserDefaults.standard
        
        if let currentXp = usrdef.value(forKey: "xp") {
            self.currentXp = currentXp as! Int
        }
        else {
            self.currentXp = 0
        }
        
        if let lvl = usrdef.value(forKey: "lvl") {
            self.lvl = lvl as! Int
        }
        else {
            self.lvl = 4
        }
    }
    
    private func lvlUp() {
        
        self.currentXp = 0
        self.lvl += 1
        
        let usrdef = UserDefaults.standard
        usrdef.set(self.lvl, forKey: "lvl")
        usrdef.set(self.currentXp, forKey: "xp")
        usrdef.synchronize()
    }
    
    public func xpGained(gained: Int) {
        
        self.currentXp += gained
        
        let usrdef = UserDefaults.standard
        usrdef.set(self.currentXp, forKey: "xp")
        usrdef.synchronize()
        
        if (self.currentXp >= self.Totalxp) {
            self.lvlUp()
        }
        
       
    }
}
