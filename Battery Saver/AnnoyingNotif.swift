//
//  AnnoyingNotif.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 10/01/2017.
//  Copyright © 2017 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON
import LNRSimpleNotifications
import AudioToolbox

class AnnoyingNotif {
    
    var url_request: String {
        let index = "\(Locale.current)".index("\(Locale.current)".startIndex, offsetBy: 3)
        let local = String("\(Locale.current)".characters.suffix(from: index)).lowercased()
        let localPars = String(local.characters.prefix(2))
        return "http://api.supreme.media:8080/request/IOS/Battery%20Saver/\(localPars)/push"
        //return "http://api.supreme.media:8080/request/IOS/Test/us/push"
    }
    var view: UIViewController!
    var appT: String!
    var desc: String!
    var link: String!
    
    init(view: UIViewController) {
        self.view = view
    }
    
    func launchPopUpMode() {
        Alamofire.request(self.url_request, method: .get).responseJSON { response in
            
            if (response.result.isFailure) {
                print("Fail push")
            }
            
            if let json = response.result.value {
                let all = JSON(json)
                
                for info in all {
                    if (info["state"].stringValue == "ACTIVATE") {
                       let alert = UIAlertController(title: info["appTitle"].stringValue, message: info["description"].stringValue, preferredStyle: .alert)
                        let res = UIAlertAction(title: "get it", style: .default, handler: { Void in
                            if let url = URL(string: info["storeLink"].stringValue) {
                                
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(url)
                                    // Fallback on earlier versions
                                }
                            }
                        })
                        let quit = UIAlertAction(title: "no thanks", style: .default, handler: { Void in
                        })
                        alert.addAction(res)
                        alert.addAction(quit)
                        self.view.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func popUp(titleApp: String, descApp: String, link: String) {
        
        let notif = LNRNotificationManager()
        
        notif.notificationsPosition = LNRNotificationPosition.top
        notif.notificationsBackgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        notif.notificationsTitleTextColor = UIColor.gray
        notif.notificationsBodyTextColor = UIColor.white
        notif.notificationsDefaultDuration = 4.0
        
        notif.showNotification(title: titleApp, body: descApp, onTap: {
            Void in
            _ = notif.dismissActiveNotification(completion: { () -> Void in
                
                print("lol \(URL(string: link))")
                if let url = URL(string: link) {
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                        // Fallback on earlier versions
                    }
                }
                
            })
        })
    }
    
    @objc func getPush(link: String) {
        print("get this link \(link)")
    }
}
