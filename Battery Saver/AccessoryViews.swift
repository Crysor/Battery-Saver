//
//  AccessoryViews.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

protocol ScoreViewProtocol {
  func scoreChanged(newScore s: Int)
}

/// A simple view that displays the player's score.
class ScoreView : UIView, ScoreViewProtocol {
  var score : Int = 0 {
    didSet {
      self.label.text = "SCORE: \(score)"
    }
  }

  let defaultFrame = CGRect(x: 3, y: 0, width: 140, height: 40)
  var label: UILabel

  init(backgroundColor bgcolor: UIColor, textColor tcolor: UIColor, font: UIFont, radius r: CGFloat) {
    self.label = UILabel(frame: defaultFrame)
    self.label.textAlignment = NSTextAlignment.center
    super.init(frame: defaultFrame)
    self.backgroundColor = bgcolor
    self.label.textColor = tcolor
    self.label.font = font
    self.layer.cornerRadius = r
    self.addSubview(self.label)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  func scoreChanged(newScore s: Int)  {
    score = s
  }
}

class TitleView: UIView {
    let defaultFrame = CGRect(x: 0, y: 0, width: 240, height: 240)
    
    var Title: UILabel
    
    init(backgroundColor bgcolor: UIColor, radius r: CGFloat) {
        self.Title = UILabel(frame: self.defaultFrame)
        super.init(frame: self.defaultFrame)
        self.Title.text = "2048"
        self.Title.textColor = UIColor.white
        self.Title.font = UIFont.boldSystemFont(ofSize: 80.0)
        self.Title.textAlignment = NSTextAlignment.center
        self.backgroundColor = bgcolor
        self.layer.cornerRadius = r
        self.addSubview(self.Title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// A simple view that displays several buttons for controlling the app
class ControlView: UIView {

    public var quitGame: UIButton
    public var resetGame: UIButton
    var HightScore: UILabel
    var Title: UILabel

    
    func reset() {
        
        let def = UserDefaults.standard
        
        if let val : Int = def.value(forKey: "best") as! Int? {
            self.HightScore.text = "BEST: \(val)"
        }
    }
    
    init(backgroundColor bgcolor: UIColor, radius r: CGFloat, width: CGFloat, height: CGFloat) {
        self.Title = UILabel(frame: CGRect(x: 5, y: 0, width: 150, height: 150))
        self.quitGame = UIButton(frame: CGRect(x: 160, y: 0, width: width - 165, height: 50))
        self.resetGame = UIButton(frame: CGRect(x: 160, y: 55, width: width - 165, height: 50))
        self.HightScore = UILabel(frame: CGRect(x: 160, y: 110, width: width - 165, height: 40))
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 150))
        
        
        self.quitGame.setTitle("Quit", for: .normal)
        self.quitGame.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        self.quitGame.setTitleColor(UIColor.white, for: .normal)
        self.quitGame.backgroundColor = UIColor.black
        self.quitGame.layer.cornerRadius = r
        self.quitGame.showsTouchWhenHighlighted = true
        
        self.resetGame.setTitle("New", for: .normal)
        self.resetGame.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        self.resetGame.setTitleColor(UIColor.white, for: .normal)
        self.resetGame.backgroundColor = UIColor.black
        self.resetGame.layer.cornerRadius = r
        self.resetGame.showsTouchWhenHighlighted = true
        
        self.Title.text = "2048"
        self.Title.textColor = UIColor.white
        self.Title.font = UIFont.boldSystemFont(ofSize: 50.0)
        self.Title.textAlignment = NSTextAlignment.center
        self.Title.layer.cornerRadius = r
        self.Title.layer.backgroundColor = UIColor.init(red: 237.0/255.0, green: 207.0/255.0, blue: 114.0/255.0, alpha: 1.0).cgColor
        
        let def = UserDefaults.standard
        
        if let score = def.value(forKey: "best") {
             self.HightScore.text = "BEST: \(score)"
        }else {
            self.HightScore.text = "BEST: 0"
        }
        
        self.HightScore.textColor = UIColor.white
        self.HightScore.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        self.HightScore.textAlignment = NSTextAlignment.center
        self.HightScore.layer.cornerRadius = r
        self.HightScore.layer.backgroundColor = UIColor.black.cgColor

        self.backgroundColor = UIColor.clear//bgcolor
        self.addSubview(self.quitGame)
        self.addSubview(self.resetGame)
        self.addSubview(self.Title)
        self.addSubview(self.HightScore)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
