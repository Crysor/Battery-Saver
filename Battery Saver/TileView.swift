//
//  TileView.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

/// A view representing a single swift-2048 tile.
class TileView : UIView {
  var value : Int = 0 {
    didSet {
      backgroundColor = delegate.tileColor(value: value)
      numberLabel.textColor = delegate.numberColor(value: value)
      numberLabel.text = "\(value)"
    }
  }

  unowned let delegate : AppearanceProviderProtocol
  let numberLabel : UILabel

  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
    
  init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol) {
    delegate = d
    numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))//CGRectMake(0, 0, width, width))
    numberLabel.textAlignment = NSTextAlignment.center
    numberLabel.minimumScaleFactor = 0.5
    numberLabel.font = delegate.fontForNumbers()

    super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))//CGRectMake(position.x, position.y, width, width))
    addSubview(numberLabel)
    layer.cornerRadius = radius

    self.value = value
    backgroundColor = delegate.tileColor(value: value)
    numberLabel.textColor = delegate.numberColor(value: value)
    numberLabel.text = "\(value)"
  }
}
