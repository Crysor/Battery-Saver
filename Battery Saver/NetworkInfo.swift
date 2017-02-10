//
//  NetworkInfo.swift
//  BatterySaver
//
//  Created by Jérémy Kerbidi on 28/09/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import CoreTelephony

class NetworkInfo {
    
    internal var CarrierName: String = ""
    
    init() {
        let networkInfo: CTTelephonyNetworkInfo! = CTTelephonyNetworkInfo()
        
        if let carrier = networkInfo.subscriberCellularProvider {
            self.CarrierName = (carrier.carrierName)!
        }else {
            self.CarrierName = "unknow"
        }
    }
    
    private func UploadSpeed(data: Int64) -> Int64 {
        
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        if (data == save.old){
            save.val = 0
        }else {
            save.val = data - save.old
            save.old = data
        }
        
        return save.val/60
        
    }
    
    private func DownloadSpeed(data: Int64) -> Int64 {
        
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        if (data == save.old){
            save.val = 0
        }else {
            save.val = data - save.old
            save.old = data
        }
        
        return save.val/60
    }
    
    public func phonePacketDownloaded(data: Int64) -> Int64 {
        
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        if (data == save.old){
            save.val = 0
        }else {
            if (save.old > 0) {
                save.val = data - save.old
            }
            save.old = data
        }
        
        return save.val
    }
    
    public func wifiPacketDownloaded(data: Int64) -> Int64 {
        
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        
        if (data == save.old){
            save.val = 0
        }else {
            if (save.old > 0) {
                save.val = data - save.old
            }
            save.old = data
        }
        
        return save.val
    }
    
    public func getWifiPacket(data: Int64) -> Int64 {
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        
        if (data == save.old){
            save.val = 0
        }else {
            if (save.old > 0) {
                save.val = data - save.old
            }
            save.old = data
        }
        
        return save.val
    }
    
    public func getPhonePacket(data: Int64) -> Int64 {
        struct save {
            static var val: Int64 = 0
            static var old: Int64 = 0
        }
        
        
        if (data == save.old){
            save.val = 0
        }else {
            if (save.old > 0) {
                save.val = data - save.old
            }
            save.old = data
        }
        
        return save.val
    }
    
    public func getPhoneData(reset: Bool) -> (Int64, Int64, Int64, Int64, String) {
        
        /*struct State {
            static var dl: Int64 = 0
        }*/
        
        var dl: Int64 = 0
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        var networkData: UnsafeMutablePointer<if_data>
        guard getifaddrs(&ifaddr) == 0 else { return (0, 0, 0,0, "") }
        guard let firstAddr = ifaddr else { return (0, 0, 0,0, "") }
        
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            let name = String(cString: interface.ifa_name)
            let data_interface = interface.ifa_data
            networkData = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            
            if name.hasPrefix("pdp_ip0") {
                if data_interface != nil {
                    if (reset) {
                        let userpref = UserDefaults.standard
                        
                        userpref.set(Double(0), forKey: "phoneData")
                        userpref.synchronize()
                        
                        //State.dl = Int64(userpref.object(forKey: "phoneData") as! Double)
                        dl = Int64(userpref.object(forKey: "phoneData") as! Double)
                        
                        return (Int64(dl), Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_obytes)), "statusListPhoneDataUsed".localized)

                        //return (Int64(State.dl), Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_obytes)), "phone_datarcv_data_cell".localized)
                    }
                    else {
                        
                        let userpref = UserDefaults.standard
                        
                        if (userpref.value(forKey: "phoneData") != nil) {
                            dl = Int64(userpref.object(forKey: "phoneData") as! Double)
                            //State.dl = Int64(userpref.object(forKey: "phoneData") as! Double)
                        }
                        else {
                            dl = Int64(networkData.pointee.ifi_ibytes)
                            //State.dl = Int64(networkData.pointee.ifi_ibytes)
                        }
                        
                        dl += self.phonePacketDownloaded(data: Int64(networkData.pointee.ifi_ibytes))
                        //State.dl += self.phonePacketDownloaded(data: Int64(networkData.pointee.ifi_ibytes))
                        
                        userpref.set(Double(dl), forKey: "phoneData")
                        //userpref.set(Double(State.dl), forKey: "phoneData")
                        userpref.synchronize()
                        
                        return (dl, Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_obytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), "statusListPhoneDataUsed".localized)
                    }
                }
            }
        }
        return (0, 0, 0, 0, "")
    }
    
    public func getWifiData(reset: Bool) -> (Int64, Int64, Int64, Int64, String) {
        
        /*struct State {
            static var dl: Int64 = 0
        }*/
        
        var dl: Int64 = 0
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        var networkData: UnsafeMutablePointer<if_data>
        guard getifaddrs(&ifaddr) == 0 else { return (0, 0, 0,0, "") }
        guard let firstAddr = ifaddr else { return (0, 0, 0,0, "") }
        
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            let name = String(cString: interface.ifa_name)
            let data_interface = interface.ifa_data
            networkData = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>.self)
           
            if name.hasPrefix("en0") {
                if data_interface != nil {
                    
                    if (reset) {
                        let userpref = UserDefaults.standard
                       
                        userpref.set(Double(0), forKey: "wifiData")
                        userpref.synchronize()
                        
                        dl = Int64(userpref.object(forKey: "wifiData") as! Double)

                       //State.dl = Int64(userpref.object(forKey: "wifiData") as! Double)
                        
                        return (Int64(dl), Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_obytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), "statusListPhoneWifiUsed".localized)//"wifi_datarcv_data_cell".localized)
                        //return (Int64(State.dl), Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_obytes)), "WIFI DATA RECEIVE")//"wifi_datarcv_data_cell".localized)
                    }
                    else {
                        
                        let userpref = UserDefaults.standard
                        
                        if (userpref.value(forKey: "wifiData") != nil) {
                            dl = Int64(userpref.object(forKey: "wifiData") as! Double)
                            //State.dl = Int64(userpref.object(forKey: "wifiData") as! Double)
                        }
                        else {
                            dl = Int64(networkData.pointee.ifi_ibytes)//Int64(userpref.object(forKey: "wifiData") as! Double)
                           //State.dl = Int64(networkData.pointee.ifi_ibytes)//Int64(userpref.object(forKey: "wifiData") as! Double)
                        }
                        
                        dl += self.wifiPacketDownloaded(data: Int64(networkData.pointee.ifi_ibytes))

                        //State.dl += self.wifiPacketDownloaded(data: Int64(networkData.pointee.ifi_ibytes))
                        
                        userpref.set(Double(dl), forKey: "wifiData")
                        //userpref.set(Double(State.dl), forKey: "wifiData")
                        userpref.synchronize()
                        
                        return (dl, Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_obytes)), "statusListPhoneWifiUsed".localized)//"wifi_datarcv_data_cell".localized)

                        //return (State.dl, Int64(networkData.pointee.ifi_obytes), self.DownloadSpeed(data: Int64(networkData.pointee.ifi_ibytes)), self.UploadSpeed(data: Int64(networkData.pointee.ifi_obytes)), "WIFI DATA RECEIVE")//"wifi_datarcv_data_cell".localized)
                    }
                }
            }
        }
        
        return (0, 0, 0, 0, "")
    }
    
    public func getLabelActif() -> String {
        let reach = Reachability()
        
        if (reach?.isReachableViaWiFi)! {
            return "statusListPhoneWifiUsed".localized
        }
        else {
            return "statusListPhoneDataUsed".localized
        }
    }
    
    public func getActif() -> String {
        let reach = Reachability()
        
        if (reach?.isReachableViaWiFi)! {
            return "wifi"
        }else {
            return "phone"
        }
    }
    
    //call in each frame TODO: a modifier
    public func getData() -> (Int64, Int64, Int64, Int64, String) {
        
        let reach = Reachability()
        
        if (reach?.isReachableViaWiFi)! {
            return self.getWifiData(reset: false)
        }else {
            return self.getPhoneData(reset: false)
        }
    }
    
    // call in each frame
    public func getIpAddress() -> String {
        var address : String = "offline".localized
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "" }
        guard let firstAddr = ifaddr else { return "" }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
                if name == "pdp_ip0" {
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }

}
