//
//  DailyAppsViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/01/2017.
//  Copyright © 2017 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import Alamofire
import JASON
import CoreData

class DailyAppsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var descContent: UILabel!
    @IBOutlet weak var descTitle: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var editor: UILabel!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var leaf: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var getIt: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var infoAppView: UIView!
    
    var urlRequest: String {
        let local = Locale.current
        return "http://api.supreme.media:8080/request/IOS/MegaApp/us/app_day"
    }
    
    var storeLink: String!
    var idApp: String!
    var kCellHeight: CGFloat = 400
    var test = [ItemAppDay]()
    var cache = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: trad
        
        self.logo.layer.cornerRadius = 17
        self.logo.clipsToBounds = true
        self.getIt.layer.cornerRadius = 5
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 61/255, green: 194/255, blue: 171/255, alpha: 0.7)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.leaf.imageInsets = UIEdgeInsetsMake(0, 17, 0, -17)
        self.tableView.separatorStyle = .none
        
        self.tableView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        //self.reachApi()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reachApi()
        self.showWaitOverlayWithText("Loading")
    }
    
    private func reachApi() {
        
        Alamofire.request(self.urlRequest, method: .get).responseJSON { response in
            
            if (response.result.isSuccess) {
                print("y'a internet")
                self.infoAppView.isHidden = false
                self.descriptionView.isHidden = false
                self.tableView.isHidden = false
                self.load()
            }
            else {
                print("y'a pas internet")
                if let appName: String = self.cache.value(forKey: "appTitle") as! String? {
                    self.appTitle.text = appName
                }
                if let desc: String = self.cache.value(forKey: "desc") as! String? {
                    self.descContent.text = desc
                }
                if let edit: String = self.cache.value(forKey: "compname") as! String? {
                    self.editor.text = edit
                }
                if let price: String = self.cache.value(forKey: "oldPrice") as! String? {
                    self.price.attributedText = NSAttributedString(string: price, attributes: [NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)])
                }
                if let link: String = self.cache.value(forKey: "storeLink") as! String? {
                    self.storeLink = link
                }
                if let id: String = self.cache.value(forKey: "appID") as! String? {
                    if let icon: Data = self.cache.object(forKey: id) as! Data? {
                        self.logo.image = UIImage(data: icon)
                    }
                }
                if let urls: [String] = self.cache.object(forKey: "dailyURLS") as! [String]? {
                    for url in urls {
                        
                        self.test.append(ItemAppDay(urls: urls, table: self.tableView))
                        let item = self.test[0]
                        
                        if (self.cache.object(forKey: url) != nil)  {
                            print("from cache trololo")
                            let pic = self.cache.object(forKey: url) as! Data
                            item.images.append(UIImage(data: pic)!)
                            DispatchQueue.main.async{
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                self.infoAppView.isHidden = false
                self.descriptionView.isHidden = false
                self.tableView.isHidden = false
                self.removeAllOverlays()
            }
            
        }
    }
    
    private func load() {
        
        //TODO : URL  IOS/local/app_day
        Alamofire.request(self.urlRequest, method: .get).responseJSON { response in
            
            if (response.result.isSuccess) {
                print("success")
                self.removeAllOverlays()
            }
            else {
                print("fail")
                self.removeAllOverlays()
            }
            
            if let json = response.result.value {
                let items = JSON(json)
                
                for item in items {
                    if (item["place"].intValue == 1) {
                        
                        
                        self.appTitle.text = item["appTitle"].stringValue
                        self.cache.set(item["appTitle"].stringValue, forKey: "appTitle")
                        
                        self.descContent.text = item["description"].stringValue
                        self.cache.set(item["description"].stringValue, forKey: "desc")
                        
                        self.editor.text = item["companyname"].stringValue
                        self.cache.set(item["companyname"].stringValue, forKey: "compname")
                        
                        self.price.attributedText = NSAttributedString(string: item["oldPrice"].stringValue, attributes: [NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)])
                        self.cache.set(item["oldPrice"].stringValue, forKey: "oldPrice")
                        
                        self.test.append(ItemAppDay(urls: item["picture"].arrayValue as! [String], table: self.tableView))
                        self.cache.set(item["picture"].arrayValue as! [String], forKey: "dailyURLS")
                        
                        DispatchQueue.global().async {
                            self.getPicture()
                        }
                        
                        
                        self.idApp = item["_id"].stringValue
                        self.cache.set(item["_id"].stringValue, forKey: "appID")
                        
                        self.storeLink = item["storeLink"].stringValue
                        self.cache.set(item["storeLink"].stringValue, forKey: "storeLink")
                        
                        self.cache.synchronize()
                        
                        let picture = item["iconLink"].stringValue
                        
                        let preferences = UserDefaults.standard
                        
                        if (preferences.object(forKey: self.idApp) != nil){
                            let Data = preferences.object(forKey: self.idApp) as! Data
                            self.logo.image = UIImage(data: Data)
                        }
                        else {
                            Alamofire.request(picture).responseData { response in
                                
                                if (response.result.isSuccess) {
                                   
                                }
                                
                                if let data = response.result.value {
                                    self.logo.image = UIImage(data: data)
                                    
                                    let photo = UserDefaults.standard
                                    photo.set(data, forKey: self.idApp)
                                    photo.synchronize()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getPicture() {
        
        let item = self.test[0]
        
            for url in item.URLS {
                
                if (self.cache.object(forKey: url) != nil)  {
                    print("from cache")
                    let pic = self.cache.object(forKey: url) as! Data
                    item.images.append(UIImage(data: pic)!)
                    //self.tableView.reloadData()
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                else {
                    Alamofire.request(url).responseData { response in
                
                        if (response.result.isSuccess) {
                            print("success")
                            
                            //self.tableView.beginUpdates()
                        }
                        else {
                            print("fail pics")
                        }
                
                        if let data = response.result.value {
                           // DispatchQueue.main.async {
                                item.images.append(UIImage(data: data)!)
                                self.cache.set(data, forKey: url)
                                self.cache.synchronize()
                            /*DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }*/
                          //  }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        /*DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }*/
                    }
                }
        }
        
        /*DispatchQueue.main.async {
            self.tableView.reloadData()
        }*/
    }
 
    @IBAction func getApp(_ sender: Any) {
        
         self.tableView.reloadData()
        //popup fail connect
       /* if let url = self.storeLink {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }*/
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.kCellHeight
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.test.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CellPortrait")
      
       if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CellPortrait")
            cell?.selectionStyle = .none
            
          let horizontalScrollView: ASHorizontalScrollView = ASHorizontalScrollView(frame:CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height))
            
            horizontalScrollView.backgroundColor = UIColor.clear
            
            if indexPath.row == 0 {
                
                horizontalScrollView.uniformItemSize = CGSize(width: 200, height:  self.kCellHeight)
                
                let item = self.test[0]
                
                for i in 0..<item.images.count {
                    let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: self.kCellHeight))
                    img.image = item.images[i]
                    horizontalScrollView.addItem(img)
                }
            }
            
            cell?.contentView.addSubview(horizontalScrollView)
            cell?.backgroundColor = UIColor.clear
            horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false
            cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.kCellHeight))
            cell?.contentView.addConstraint(NSLayoutConstraint(item: horizontalScrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: cell!.contentView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0))
        }
       
        return cell!
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
