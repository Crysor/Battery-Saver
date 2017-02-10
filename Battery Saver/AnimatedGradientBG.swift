//
//  AnimatedGradientBG.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 10/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBlurForLabel() -> UIBlurEffect {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.tag = 2
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
        
        return blurEffect
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.tag = 1
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffecrt() {
        
        for view in self.subviews {
            if (view.tag == 1) {
                view.removeFromSuperview()
            }
            if (view.tag == 2) {
                view.removeFromSuperview()
            }
        }
    }
    
    private struct colors_bg {
        let Green = UIColor(red: 57/255, green: 240/255, blue: 169/255, alpha: 1).cgColor
        let Cyan = UIColor(red: 61/255, green: 172/255, blue: 165/255, alpha: 1).cgColor
        let Yellow = UIColor(red: 252/255, green: 205/255, blue: 40/255, alpha: 1).cgColor
        let Orange =  UIColor(red: 244/255, green: 136/255, blue: 78/255, alpha: 1).cgColor
        let Red = UIColor(red: 245/255, green: 80/255, blue: 58/255, alpha: 1).cgColor
        let Pink = UIColor(red: 227/255, green: 73/255, blue: 127/255, alpha: 1).cgColor
    }
    
    func defaulLayerGradient() -> CAGradientLayer {
        
        let colors = colors_bg()
        
        self.layer.sublayers = self.layer.sublayers?.filter(){!($0 is CAGradientLayer)}
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.colors = [colors.Green, colors.Cyan]
        self.layer.insertSublayer(layer, at: 0)
        
        return layer
    }
    
    func layerGradient(colors: [CGColor]) -> CAGradientLayer {
        
        self.layer.sublayers = self.layer.sublayers?.filter(){!($0 is CAGradientLayer)}
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.colors = colors
        self.layer.insertSublayer(layer, at: 0)

        return layer
    }
    
    func layerGradient() -> CAGradientLayer {
        
        //let device = UIDevice.current
        //device.isBatteryMonitoringEnabled = true
        let lvl = BatteryInfo().BatteryLevel()
        
        let colors = colors_bg()
        
        self.layer.sublayers = self.layer.sublayers?.filter(){!($0 is CAGradientLayer)}
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        if (lvl > 50) {
            layer.colors = [colors.Green, colors.Cyan]
        }
        else if (lvl <= 50 && lvl > 20 ) {
            layer.colors = [colors.Yellow, colors.Orange]
        }
        else if (lvl <= 20) {
            layer.colors = [colors.Red, colors.Pink]
        }
        
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }
    
    func animateLayerGradient(gradient: CAGradientLayer, lvl: Int){
        
        let fromColors = gradient.colors
        var toColors: [CGColor]!
        
        let colors = colors_bg()
        
        if (lvl > 50) {
            toColors = [colors.Green, colors.Cyan]
        }
        else if (lvl <= 50 && lvl > 20 ) {
            toColors = [colors.Yellow, colors.Orange]
        }
        else if (lvl <= 20) {
            toColors = [colors.Red, colors.Pink]
        }
        
        gradient.colors = toColors
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 1.0
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        gradient.add(animation, forKey: "animateGradient")
    }
}
