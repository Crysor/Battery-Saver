//
//  MoreViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Foundation
import MessageUI
import Social

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    var timer : Timer!
    var battery_info: BatteryInfo!
    var gradient: CAGradientLayer!
    var tools: Tools!
    var device: DeviceInfo!
    static var battery : Int = 0
    @IBOutlet weak var table_more: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var BannerView: GADNativeExpressAdView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    var gtracker: TrackerGoogle!
    @IBOutlet weak var titlePage: UILabel!
    @IBOutlet weak var labelSystem: UILabel!
    @IBOutlet weak var labelMoreApps: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titlePage.text = "regPageMore".localized
        
        self.playBtn.setTitle("morePlay".localized, for: .normal)
        self.labelSystem.text = "moreSystem".localized
        self.labelMoreApps.text = "More Apps"
        
       var tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.share))
        self.btnShare.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.shareFacebook))
        self.btnFacebook.addGestureRecognizer(tapGestureRecognizer)
        
        self.playBtn.layer.cornerRadius = 5
        
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "More")
        
        let banner = Banner(banner: self.BannerView, adsize: kGADAdSizeSmartBannerPortrait, controller: self)
        banner.LoadNative()
        
        
        self.tools = Tools()
        self.device = DeviceInfo()
        self.battery_info = BatteryInfo()
        self.setupSwipeControls()
    }
    
    func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["support@spicy-apps.com"])
        mailComposerVC.setSubject("\(self.device.Model)/\(self.device.Version)/Battery Life")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let quit = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(quit)
        present(alert, animated: true, completion: nil)
    }
    
    func setupSwipeControls() {
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.rightCommand(r:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        self.gtracker.setEvent(category: "more", action: "swipe_data", label: "swipe")
        self.tabBarController?.selectedIndex = 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tools.animateTable(table: self.table_more)
        self.gradient = self.view.layerGradient()
        
        let mon = MonitorManager(target: self, sel: #selector(self.MonitoringState))
        self.timer = mon.MonitorHandler()
    }
    
    @objc private func MonitoringState() {
        
        self.view.animateLayerGradient(gradient: self.gradient, lvl: self.battery_info.BatteryLevel())
        self.gradient.animation(forKey: "animateGradient")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.timer.invalidate()
        self.timer = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(68)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = self.table_more.dequeueReusableCell(withIdentifier: "Feedback")!
        case 1:
            cell = self.table_more.dequeueReusableCell(withIdentifier: "RateUs")!
        default:
            break
        }
        
        return cell
    }
    
    @IBAction func System(_ sender: Any) {
        
        self.gtracker.setEvent(category: "more", action: "system", label: "click")
    }
    
    @IBAction func runGame(_ sender: AnyObject) {
        
        self.gtracker.setEvent(category: "more", action: "2048", label: "click")

        let game = NumberTileGameViewController(dimension: 4, threshold: 2048)
        self.present(game, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            case 0:
                self.gtracker.setEvent(category: "more", action: "feedback", label: "swipe")
                sendEmail()
            case 1:
                self.gtracker.setEvent(category: "more", action: "rate", label: "click")

                let url = "https://itunes.apple.com/app/id1182972110"
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(NSURL(string : url) as! URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(NSURL(string : url) as! URL)
                }
                let userdef = UserDefaults.standard
                userdef.set(404, forKey: "event")
                userdef.synchronize()
            default: break
            
        }
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 0.3)
        if let indexPath = tableView.indexPathForSelectedRow
        {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let additionalSeparatorThickness = CGFloat(5)
        let additionalSeparator = UIView(frame: CGRect(x: 0, y: (cell.frame.size.height - additionalSeparatorThickness) + 1, width: cell.frame.size.width, height: additionalSeparatorThickness))
        additionalSeparator.backgroundColor = UIColor.clear
        additionalSeparator.alpha = CGFloat(0.5)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.addSubview(additionalSeparator)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
   
    @objc private func shareFacebook() {

        if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
            
            self.gtracker.setEvent(category: "more", action: "share_facebook", label: "click")

            vc.add(URL(string: "https://itunes.apple.com/app/id1182972110"))
            present(vc, animated: true)
        }
    }
    
    @IBAction func DailyApp(_ sender: Any) {
        
        self.gtracker.setEvent(category: "more", action: "dailyapps", label: "click")
    }
    
    @IBAction func MoreApps(_ sender: Any) {
        self.gtracker.setEvent(category: "more", action: "moreapps", label: "click")
    }
    
    @objc private func share() {

        if (MFMessageComposeViewController.canSendText()) {
            
            self.gtracker.setEvent(category: "more", action: "share_sms", label: "click")

            let controller = MFMessageComposeViewController()
            controller.body = "smsText".localized
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
}
