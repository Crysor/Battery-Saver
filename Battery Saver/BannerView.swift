//
//  BannerView.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 23/11/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit
import GoogleMobileAds

class Banner {
    
    var debug: Bool = false // true for debug mode
    var banner: GADBannerView!
    var native: GADNativeExpressAdView!
    var size : GADAdSize!
    var controller: UIViewController!
    
    init(banner: GADBannerView, adsize: GADAdSize, controller: UIViewController) {
        self.banner = banner
        self.size = adsize
        self.controller = controller
    }
    
    init(banner: GADNativeExpressAdView, adsize: GADAdSize, controller: UIViewController) {
        self.native = banner
        self.size = adsize
        self.controller = controller
    }
    
    public func LoadNative() {
        self.native.adSize = self.size
        self.native.adUnitID = "ca-app-pub-3804885476261021/6701160996"//"ca-app-pub-3804885476261021/2398840596"
        self.native.rootViewController = self.controller
        let req : GADRequest = GADRequest()

        if (self.debug == true) {
            req.testDevices = ["71d8d952dacdd2cb3fe4e4065d2c0e06"]
            self.native.load(req)
        }
        else {
            self.native.load(req)
        }
    }
    
    public func LoadNative2() -> GADNativeExpressAdView {
        self.native.adSize = self.size
        self.native.adUnitID = "ca-app-pub-3804885476261021/6701160996"//"ca-app-pub-3804885476261021/2398840596"
        self.native.rootViewController = self.controller
        let req : GADRequest = GADRequest()
        
        if (self.debug == true) {
            req.testDevices = ["71d8d952dacdd2cb3fe4e4065d2c0e06"]
            self.native.load(req)
        }
        else {
            self.native.load(req)
        }
        
        return self.native
    }
    
    public func Load() {
        self.banner.adSize = self.size
        self.banner.adUnitID = "ca-app-pub-3804885476261021/2270961393"//"ca-app-pub-3804885476261021/3208569391"
        self.banner.rootViewController = self.controller
        let req : GADRequest = GADRequest()
        
        if (self.debug == true) {
            req.testDevices = ["71d8d952dacdd2cb3fe4e4065d2c0e06"]
            self.banner.load(req)
        }
        else {
            self.banner.load(req)
        }
    }
    
    public func Load2() -> GADBannerView {
        self.banner.adSize = self.size
        self.banner.adUnitID = "ca-app-pub-3804885476261021/2270961393"//"ca-app-pub-3804885476261021/3208569391"
        self.banner.rootViewController = self.controller
        let req : GADRequest = GADRequest()
        
        if (self.debug == true) {
            req.testDevices = ["71d8d952dacdd2cb3fe4e4065d2c0e06"]
            self.banner.load(req)
        }
        else {
            self.banner.load(req)
        }
        
        return self.banner
    }
}
