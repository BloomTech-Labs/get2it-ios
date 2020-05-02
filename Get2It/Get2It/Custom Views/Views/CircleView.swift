//
//  CircleView.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/8/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

// Private Constants
private let kDiameter = CGFloat(20.0)

class CircleView: UIView {
    private let trackLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    var isChecked: Bool = false {
        didSet {
            innerCircleLayer.isHidden = !isChecked
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: kDiameter, height: kDiameter)
    }
    
    init() {
        super.init(frame: .zero)
        
        let center = CGPoint(x: kDiameter / 2, y: kDiameter / 2)
        
        // circle
        let circularPath = UIBezierPath(arcCenter: center, radius: kDiameter / 2, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.gray.cgColor
        trackLayer.lineWidth = 2
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(trackLayer)
        
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // inner circle
        let spacer = CGFloat(8.0)
        
        let innerCircle = UIBezierPath(ovalIn: CGRect(x: spacer/2, y: spacer/2, width: kDiameter - spacer, height: kDiameter - spacer))
        innerCircleLayer.isHidden = true
        innerCircleLayer.path = innerCircle.cgPath
        innerCircleLayer.fillColor = UIColor(red: 5/255, green: 91/255, blue: 195/255, alpha: 1).cgColor
        
        layer.addSublayer(innerCircleLayer)
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

