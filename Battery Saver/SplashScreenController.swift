//
//  SplashScreenController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 28/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class SplashScreenController: UIViewController {
    
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var battery: UIImageView!
    @IBOutlet weak var flash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perform(#selector(self.endSplash), with: nil, afterDelay: 1.0)
    }
    
    func endSplash() {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.performSegue(withIdentifier: "splash", sender: nil)
        })
        self.battery.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.flash.center.y = 130
            self.flash.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.flash.alpha = 0.5
            
        })
        CATransaction.commit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
