//
//  AppDayCell.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 05/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON

class AppDayCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    var storeLink: URL!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //TODO: URL
        Alamofire.request("http://api.supreme.media:8080/request/ANDROID/AAA/us/app_day", method: .get).responseJSON { response in
            
            if (response.result.isSuccess) {
                print("success")
            }
            else {
                print("fail: \(response.result.error)")
            }
            
            if let json = response.result.value {
                let items = JSON(json)
                
                for item in items {
                    
                    if (item["place"].intValue == 1) {
                        self.storeLink = URL(string: item["storeLink"].stringValue)
                        self.name.text = item["appTitle"].stringValue
                        
                        let preferences = UserDefaults.standard
                        
                        if (preferences.object(forKey: item["picture"][1].stringValue) != nil){
                            let Data = preferences.object(forKey: item["picture"][1].stringValue) as! Data
                            self.img.image = UIImage(data: Data)
                            
                            OperationQueue.main.addOperation {
                                
                            }
                        }
                        else {
                            Alamofire.request(item["picture"][1].stringValue).responseData { response in
                                
                                if (response.result.isSuccess) {
                                    print("success")
                                }
                                else {
                                    print("fail image: \(response.result.error)")
                                }

                                
                                if let data = response.result.value {
                                    
                                    
                                    self.img.image = UIImage(data: data)
                                    
                                    let photo = UserDefaults.standard
                                    photo.set(data, forKey: item["picture"][1].stringValue)
                                    photo.synchronize()
                                }
                                
                                OperationQueue.main.addOperation {
                                    //tab.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
