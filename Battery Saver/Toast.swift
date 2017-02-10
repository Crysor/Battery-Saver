//
//  Toast.swift
//  BatterySaver
//
//  Created by Jérémy Kerbidi on 19/09/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import Foundation

class Toast {
    
    var view: UIView!
    var msg: String!
    
    init?(view: UIView, msg: String){
        self.view = view
        self.msg = msg
    }
    
    func Show(){
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height, width: 300, height: 35))
        
        
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        self.view.addSubview(toastLabel)
        toastLabel.text = self.msg
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
            
            }, completion: nil)
    }
    
    func Show(frame: CGRect, bgColor: UIColor, txtColor: UIColor, interval: TimeInterval) {
        let toastLabel = UILabel(frame: frame)
        
        
        toastLabel.backgroundColor = bgColor
        toastLabel.textColor = txtColor
        toastLabel.textAlignment = NSTextAlignment.center;
        self.view.addSubview(toastLabel)
        toastLabel.text = self.msg
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: interval, delay: 0.1, options: .curveEaseOut, animations: {
            
            toastLabel.alpha = 0.0
            
        }, completion: nil)
    }
}
