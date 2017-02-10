//
//  Circle.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 11/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class Circle: UIView {
    
    public var circleLayer: CAShapeLayer!
    static var OldVal: CGFloat = 0.0
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 1.58, endAngle: CGFloat(M_PI * 2.51), clockwise: true)

        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = circlePath.cgPath
        self.circleLayer.fillColor = UIColor.clear.cgColor
       
        self.circleLayer.strokeEnd = 1.0
        
        layer.addSublayer(self.circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func AnimatedCircle(PercentValue: CGFloat, Duration: CFTimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = Duration
        
        animation.fromValue = 0
        animation.toValue = PercentValue
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        self.circleLayer.strokeEnd = PercentValue
        
        self.circleLayer.add(animation, forKey: "animateCircle")
    }
}
