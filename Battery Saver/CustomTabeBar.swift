//
//  CustomeTabeBar.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 24/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func tuto() -> (Bool,  CALayer) {
        
        //TODO check userdefault
        let mask = CALayer()
        mask.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        mask.backgroundColor = UIColor.black.cgColor
        mask.opacity = 0.5
        
        self.view.layer.mask = mask
        
        return (true, mask)
    }
}

class CustomTabBar: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet var gesture: UISwipeGestureRecognizer!
    var gtracker: TrackerGoogle!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.gtracker = TrackerGoogle()

        self.tabBar.tintColor = UIColor.white
        if let items = self.tabBar.items
        {
            items[0].title = "regPageStatus".localized
            items[1].title = "regPageCharge".localized
            items[2].title = "regPageMemory".localized
            items[3].title = "regPageData".localized
            items[4].title = "regPageMore".localized
            
            for item in items
            {
                
                if let image = item.image
                {
                    item.image = image.withRenderingMode( .alwaysOriginal )
                }
            }
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
       
        
        switch tabBarIndex {
        case 0:
            self.gtracker.setEvent(category: "toolbar", action: "status", label: "click")
        case 1:
            self.gtracker.setEvent(category: "toolbar", action: "charge", label: "click")
        case 2:
            self.gtracker.setEvent(category: "toolbar", action: "memory", label: "click")
        case 3:
            self.gtracker.setEvent(category: "toolbar", action: "data", label: "click")
        case 4:
            self.gtracker.setEvent(category: "toolbar", action: "more", label: "click")
        default:break
        }
    }
    
    /*public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let fromView: UIView = tabBarController.selectedViewController!.view
        let toView  : UIView = viewController.view
        if fromView == toView {
            return false
        }
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve) { (finished:Bool) in
        }
        return true
    }*/
}
