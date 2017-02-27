//
//  DataViewController.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import Charts

class NetworkDataViewController: UIViewController {
    
   var timer : Timer!
    var saver: Timer!
    @IBOutlet weak var PhoneData: UILabel!
    @IBOutlet weak var WifiData: UILabel!
    var networkInfo: NetworkInfo!
    var tools: Tools!
    var battery_info: BatteryInfo!
    var gradient: CAGradientLayer!
    var PhoneValues: [Double]!
    var WifiValues: [Double]!
    @IBOutlet weak var LineChartView: LineChartView!
    static var PhonePacket: Int64 = 0
    static var WifiPacket: Int64 = 0
    @IBOutlet weak var btnreset: UIButton!

    @IBOutlet weak var labelPhoneTotal: UILabel!
    @IBOutlet weak var labelWifiTotal: UILabel!
    @IBOutlet weak var labelGraphTotal: UILabel!
    
    var background : UIBackgroundTaskIdentifier!
    var gtracker: TrackerGoogle!
    
    @IBOutlet weak var phoneActif: UILabel!
    @IBOutlet weak var wifiActif: UILabel!
    @IBOutlet weak var nodata: UILabel!
    @IBOutlet weak var titlePage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titlePage.text = "regPageData".localized
        self.btnreset.setTitle("dataReset".localized, for: .normal)
        
        self.labelPhoneTotal.text = "dataTotalDataUsed".localized
        self.labelWifiTotal.text = "dataTotalWifiUsed".localized
        self.labelGraphTotal.text = "dataTotalphonedataused".localized
        
        self.LineChartView.layer.zPosition = 0
        self.nodata.layer.zPosition = 1
        self.btnreset.layer.cornerRadius = 17
        self.btnreset.layer.cornerRadius = 17
        self.gtracker = TrackerGoogle()
        self.gtracker.setScreenName(name: "Data")
       
        self.tools = Tools()
        self.battery_info = BatteryInfo()
        self.networkInfo = NetworkInfo()
        self.PhoneValues = [Double]()
        self.WifiValues = [Double]()
        self.setActif()
        
        self.setGraphStyle()
        self.drawDataGraph()
        self.setupSwipeControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.setVals()
        self.gradient = self.view.layerGradient()
        
        self.PhoneData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getPhoneData(reset: false).0)
        self.WifiData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getWifiData(reset: false).0)
        
        let mon = MonitorManager(target: self, sel: #selector(self.MonitoringState))
        self.timer = mon.MonitorHandler()
        
        self.setGraphStyle()
        self.drawDataGraph()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer.invalidate()
        self.timer = nil
    }
    
    
    @objc private func goToMore() {
        self.tabBarController?.selectedIndex = 4
    }
    
    private func setActif() {
        
        if (self.networkInfo.getActif() == "phone") {
            self.phoneActif.text = "ON"
            self.wifiActif.text = "OFF"
            self.phoneActif.textColor = UIColor(red: 61/255, green: 64/255, blue: 68/255, alpha: 1)
            self.wifiActif.textColor = UIColor(red: 143/255, green: 147/255, blue: 156/255, alpha: 1)
        }
        else if (self.networkInfo.getActif() == "wifi") {
            self.phoneActif.text = "OFF"
            self.wifiActif.text = "ON"
            self.wifiActif.textColor = UIColor(red: 61/255, green: 64/255, blue: 68/255, alpha: 1)
            self.phoneActif.textColor = UIColor(red: 143/255, green: 147/255, blue: 156/255, alpha: 1)
        }
        else {
            self.phoneActif.text = "OFF"
            self.wifiActif.text = "OFF"
            self.wifiActif.textColor = UIColor(red: 143/255, green: 147/255, blue: 156/255, alpha: 1)
            self.phoneActif.textColor = UIColor(red: 143/255, green: 147/255, blue: 156/255, alpha: 1)
        }
        
        if (self.PhoneValues.max() == 0.0 && self.WifiValues.max() == 0.0){
            self.nodata.isHidden = false
            self.nodata.layer.zPosition = 1
        }
        else {
            self.nodata.isHidden = true
            self.nodata.layer.zPosition = 1
        }
    }
    
    private func setupSwipeControls() {
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.leftCommand(r:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.rightCommand(r:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    private func setVals() {
        
        let userdef = UserDefaults.standard
        let today = DateFormatter()
        today.dateFormat = "dd/MM/yy"
        let todayString = today.string(from: Date())
        
        if let wifi = userdef.value(forKey: "wifi-historic-"+todayString) {
            self.WifiValues = wifi as! [Double]
        }
        else {
            NSLog("Fail to get wifi data")
            self.WifiValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }
        
        if let phone = userdef.value(forKey: "phone-historic-"+todayString) {
            self.PhoneValues = phone as! [Double]
        }
        else {
            NSLog("Fail to get phone data")

            self.PhoneValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }        
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        self.gtracker.setEvent(category: "data", action: "swipe_more", label: "swipe")

        self.tabBarController?.selectedIndex = 4
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        self.gtracker.setEvent(category: "data", action: "swipe_mem", label: "swipe")
        self.tabBarController?.selectedIndex = 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func MonitoringState() {
        
        self.setActif()
        
        NetworkDataViewController.PhonePacket += self.networkInfo.getPhonePacket(data: self.networkInfo.getPhoneData(reset: false).0)
        NetworkDataViewController.WifiPacket += self.networkInfo.getWifiPacket(data: self.networkInfo.getWifiData(reset: false).0)

        self.view.animateLayerGradient(gradient: self.gradient, lvl: self.battery_info.BatteryLevel())
        self.gradient.animation(forKey: "animateGradient")
        
        self.WifiData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getWifiData(reset: false).0)
        self.PhoneData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getPhoneData(reset: false).0)
    }
    
    private func setGraphStyle() {
    
        self.LineChartView.chartDescription?.text = ""
        let xAxis = XAxis()
        let xchartFormatter = ChartFormatter()
        
        for i in 0...6 {
            _ = xchartFormatter.stringForValue(Double(i), axis: xAxis)
        }
        
        xAxis.valueFormatter = xchartFormatter
        
        self.LineChartView.xAxis.valueFormatter = xAxis.valueFormatter
        
        
        let yAxis = YAxis()
        let ychartformat = ChartFormatter()
        
        for i in 0...self.LineChartView.leftAxis.labelCount {
            _ = ychartformat.stringForValue(Double(i), axis: yAxis)
        }
        
        yAxis.valueFormatter = ychartformat
        self.LineChartView.leftAxis.valueFormatter = yAxis.valueFormatter
        self.LineChartView.noDataText = "No fetched yet"
        self.LineChartView.drawBordersEnabled = false
        self.LineChartView.drawGridBackgroundEnabled = false
        self.LineChartView.xAxis.labelPosition = .top
        self.LineChartView.xAxis.drawAxisLineEnabled = false
        self.LineChartView.xAxis.drawGridLinesEnabled = true
        self.LineChartView.xAxis.labelTextColor = .gray
        self.LineChartView.xAxis.drawLabelsEnabled = true
        self.LineChartView.xAxis.axisMaximum = 6
        self.LineChartView.legend.enabled = false
        
        self.LineChartView.rightAxis.drawLabelsEnabled = true
        self.LineChartView.rightAxis.drawTopYLabelEntryEnabled = false
        self.LineChartView.rightAxis.labelTextColor = .clear
        self.LineChartView.rightAxis.drawGridLinesEnabled = false
        self.LineChartView.rightAxis.drawAxisLineEnabled = false
    
        
        self.LineChartView.leftAxis.drawLabelsEnabled = true
        self.LineChartView.leftAxis.labelTextColor = .gray
        self.LineChartView.leftAxis.drawGridLinesEnabled = false
        self.LineChartView.leftAxis.drawAxisLineEnabled = false
        self.LineChartView.leftAxis.axisMinimum = 0
    }
    
    private func PhoneGraph(entries: [ChartDataEntry]) -> LineChartDataSet {
        
        let PhonelineChartDataSet = LineChartDataSet(values: entries, label: "")
        PhonelineChartDataSet.drawCirclesEnabled = false
        PhonelineChartDataSet.valueColors = [ .clear ]
        PhonelineChartDataSet.mode = LineChartDataSet.Mode.cubicBezier
        PhonelineChartDataSet.colors = [ UIColor(colorLiteralRed: 27/255, green: 179/255, blue: 196/255, alpha: 1) ]
        PhonelineChartDataSet.drawFilledEnabled = true
        PhonelineChartDataSet.fillColor = UIColor(colorLiteralRed: 27/255, green: 179/255, blue: 196/255, alpha: 1)
        PhonelineChartDataSet.fillAlpha = 1
        
        return PhonelineChartDataSet
    }
    
    private func WifiGraph(entries: [ChartDataEntry]) -> LineChartDataSet {
        
        let WifilineChartDataSet = LineChartDataSet(values: entries, label: "")

        WifilineChartDataSet.drawCirclesEnabled = false
        WifilineChartDataSet.valueColors = [ .clear ]
        WifilineChartDataSet.mode = LineChartDataSet.Mode.cubicBezier
        WifilineChartDataSet.colors = [ UIColor(colorLiteralRed: 250/255, green: 85/255, blue: 63/255, alpha: 1) ]
        WifilineChartDataSet.drawFilledEnabled = true
        WifilineChartDataSet.fillColor = UIColor(colorLiteralRed: 250/255, green: 85/255, blue: 63/255, alpha: 1)
        WifilineChartDataSet.fillAlpha = 1
        
        return WifilineChartDataSet
    }
    
    private func drawDataGraph() {
        
        if (self.PhoneValues.count == 0 || self.PhoneValues.count == 0) {
            return
        }
        
        var PhoneDataEntries: [ChartDataEntry] = []
        var WifiDataEntries: [ChartDataEntry] = []
        
        
        for count in 0..<self.PhoneValues.count {
                
            let dataEntry = ChartDataEntry(x: Double(count), y: self.PhoneValues[count])
            PhoneDataEntries.append(dataEntry)
        }
            
        for count in 0..<self.WifiValues.count {
                
            let dataEntry = ChartDataEntry(x: Double(count), y: self.WifiValues[count])
            WifiDataEntries.append(dataEntry)
        }
        
        let phoneGraph = self.PhoneGraph(entries: PhoneDataEntries)

        let wifiGraph = self.WifiGraph(entries: WifiDataEntries)
        
        let lineChartData = LineChartData(dataSets: [phoneGraph, wifiGraph])
        self.LineChartView.animate(xAxisDuration: 0.4)
        self.LineChartView.data = lineChartData
    }
    
    // set axis values
    @objc(BarChartFormatter)
    class ChartFormatter:NSObject,IAxisValueFormatter{
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            
            if (axis?.isKind(of: XAxis.self))! {
                
                let date = Date()
                let c = Calendar.current
                
                let df = DateFormatter()
                df.dateFormat = "H a"
                
                let userdef = UserDefaults.standard
                
               if let hours : [String] = userdef.value(forKey: "tabhours") as? [String] {
                    switch value {
                        case 0:
                            return  hours[0]
                        case 1:
                            return  hours[1]
                        case 2:
                            return  hours[2]
                        case 3:
                            return  hours[3]
                        case 4:
                            return  hours[4]
                        case 5:
                            return  hours[5]
                        case 6:
                            return  hours[6]
                        default: break
                    }
                }
                else {
                    // x axis values
                    switch value {
                    case 0:
                        let before = c.date(byAdding: .hour, value: -6, to: date)
                        return  df.string(from: before!)
                    case 1:
                        let before = c.date(byAdding: .hour, value: -5, to: date)
                        return  df.string(from: before!)
                    case 2:
                        let before = c.date(byAdding: .hour, value: -4, to: date)
                        return  df.string(from: before!)
                    case 3:
                        let before = c.date(byAdding: .hour, value: -3, to: date)
                        return  df.string(from: before!)
                    case 4:
                        let before = c.date(byAdding: .hour, value: -2, to: date)
                        return  df.string(from: before!)
                    case 5:
                        let before = c.date(byAdding: .hour, value: -1, to: date)
                        return  df.string(from: before!)
                    case 6:
                        let before = c.date(byAdding: .hour, value: 0, to: date)
                        return  df.string(from: before!)
                    default: break
                    }
               }
            }
            else {
                // Y axis values
                if (value >= 1000000000) {
                    return "\(Int(value) / 1000000000) GB"
                }
                else if (value >= 1000000) {
                    return "\(Int(value) / 1000000) MB"
                }
                else if (value >= 1000) {
                    return "\(Int(value) / 1000) KB"
                }
                else if (value > 1) {
                    return "\(value) B"
                }
                else if (value == 1) {
                    return "\(value) B"
                }
                else {
                    return "0 B"
                }
            }
            return ""
        }
    }
    
    @IBAction func MoreApps(_ sender: Any) {
        self.gtracker.setEvent(category: "data", action: "moreapps", label: "click")
    }
    
    @IBAction func resetData(_ sender: AnyObject) {
        
        // TODO: trad
        let alertController = UIAlertController(title: "Reset", message: "Do you really want to reset the Data ?", preferredStyle: UIAlertControllerStyle.alert)
        let yesAction = UIAlertAction(title: "yes", style: .default) {
            (_) in
            
            self.WifiData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getWifiData(reset: true).0)
            self.PhoneData.text = self.tools.formatSizeUnits(bytes: self.networkInfo.getPhoneData(reset: true).0)
        }
        let noAction = UIAlertAction(title: "no", style: .cancel) { (_) in }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)

        self.present(alertController, animated: true, completion: nil)
    }
}
