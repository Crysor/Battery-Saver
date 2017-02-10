//
//  tracker.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 13/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class TrackerGoogle {
    
    var debug: Bool = false // set true for debug mode
    var tracker: GAITracker!
    
    init() {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            print("gros fail")
            return
        }
        self.tracker = tracker
    }
    
    func setScreenName(name: String) {
        if (self.debug == false) {
            self.tracker?.set(kGAIScreenName , value: name)
            let build = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
            self.tracker?.send(build)
        }
        else {
            print("anylitics debbug")
        }
    }
    
    func setEvent(category: String, action: String, label: String) {
        if (self.debug == false) {
            let build = (GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil).build() as NSDictionary) as! [AnyHashable: Any]
            self.tracker.send(build)
        }
        else {
            print("anylitics debbug")
        }

    }
}

