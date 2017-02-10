//
//  MoreAppsViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 27/12/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Alamofire
import JASON
import SwiftOverlays

class MoreAppsViewController: UITableViewController {
    
    var items = [AppItem]()
    var gtracker: TrackerGoogle!
    var url_request: String {
        //"http://api.supreme.media:8080/request/IOS/MegaApp/us/more_app"
        return "http://api.supreme.media:8080/request/IOS/Battery%20Saver/us/more_app"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: trad
        self.title = "More Apps"
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "MoreApps")
        self.loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showWaitOverlayWithText("Loading")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadItems() {
        
        //TODO: URL  IOS a la place "ANDROID" le local pour "us"
        let local = String("\(Locale.current)".characters.prefix(2))
        print("l \(local)")
        Alamofire.request(self.url_request, method: .get).responseJSON { response in
            
            if (response.result.isSuccess) {
                print("success mdr")
                self.removeAllOverlays()
            }
            else {
                print("fail lol")
                
                
                self.removeAllOverlays()
            }
            
            if let json = response.result.value {
                let items = JSON(json)
            
                for item in items {
                    
                    self.items.append(AppItem(id: item["_id"].stringValue,name: item["appTitle"].stringValue, editor: item["companyname"].stringValue, rate: item["starNumber"].stringValue, pic: item["iconLink"].stringValue, storeLink: item["storeLink"].stringValue, tab: self.tableView))
                }
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(100) //Choose your custom row height
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let additionalSeparatorThickness = CGFloat(5)
        let additionalSeparator = UIView(frame: CGRect(x: 0, y: (cell.frame.size.height - additionalSeparatorThickness) + 1, width: cell.frame.size.width, height: additionalSeparatorThickness))
        additionalSeparator.backgroundColor = UIColor.clear
        
        additionalSeparator.alpha = CGFloat(0.5)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 6)
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 5
        
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.addSubview(additionalSeparator)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "AppCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MoreAppsCellView
        
        let app_info = self.items[(indexPath as NSIndexPath).row]
        
        cell.Name.text = app_info.name
        cell.picture.image = app_info.picture
        cell.editor.text = app_info.editor
        cell.getIt = app_info.storLink
        
        let Stars = [cell.star1, cell.star2, cell.star3, cell.star4, cell.star5]
        
        var rate: Int = app_info.rate
        
        if (rate >= 5) {
            rate = 5
        }
        else if (rate <= 1) {
            rate = 1
        }
        
        for i in 0..<rate {
            Stars[i]?.isHidden = false
        }
        
        return cell
    }
}
