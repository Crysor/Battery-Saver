//
//  RateEvent.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 23/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func ratePopUp() -> (UIAlertController, Int) {
        
        let userdef = UserDefaults.standard
        let once : Int!
        let boost: Int!
        let opening: Int!
        
        if let event :Int = userdef.value(forKey: "event") as? Int {
            once = event
        }
        else {
            once = 0
        }
        
        
        
        if let open : Int = userdef.value(forKey: "open") as? Int {
            opening = open
        }
        else {
            opening = 1
        }
        
        userdef.set(opening, forKey: "open")
        userdef.synchronize()
        
        if (opening >= 3) {
            
            if let b :Int = userdef.value(forKey: "boost") as? Int {
                boost = b
            }
            else {
                boost = 0
            }
            
            userdef.set(boost, forKey: "boost")
            userdef.synchronize()
            
            if (boost >= 1) {
                if (once == 0) {
            
                    let tracker = TrackerGoogle()
                    tracker.setScreenName(name: "Ram")
                
                    let alert = UIAlertController(title: "askforrateTitle".localized, message: "askforrateText".localized, preferredStyle: .alert)
                    let rate = UIAlertAction(title: "askforratePos".localized, style: .default, handler: { _ in
                    
                        tracker.setEvent(category: "ram", action: "rate_five", label: "click")
                        let url = "https://itunes.apple.com/app/1182972110"
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(NSURL(string : url) as! URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(NSURL(string : url) as! URL)
                        }
                        alert.dismiss(animated: true, completion: nil)
                        userdef.set(404, forKey: "event")
                        userdef.synchronize()
                    })
                
                    let later  = UIAlertAction(title: "askforrateRemindMe".localized, style: .default, handler: { _ in
                        
                        tracker.setEvent(category: "ram", action: "rate_remind", label: "click")
                        
                        userdef.set(0, forKey: "boost")
                        userdef.set(0, forKey: "open")
                        userdef.set(0, forKey: "event")
                        userdef.synchronize()
                    })
                
                    let no = UIAlertAction(title: "askforrateNeg".localized, style: .cancel, handler: { _ in
                      
                        tracker.setEvent(category: "ram", action: "rate_no", label: "click")
                        
                        userdef.set(404, forKey: "event")
                        userdef.synchronize()
                    })
                
                    alert.addAction(rate)
                    alert.addAction(later)
                    alert.addAction(no)
                    return (alert, 1)
                }
           }
       }
        
        let alert = UIAlertController()
        return (alert, 0)
    }
}
