//
//  GradientView.swift
//  CustomUI
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

@IBDesignable
public class ZRGradientOverlayView: UIView {

    @IBInspectable public var innerColor: UIColor = .clear
    @IBInspectable public var outerColor: UIColor = .black
    @IBInspectable public var innerRadiusFraction: CGFloat = 0.75
    @IBInspectable public var outerRadius: CGFloat = 50
    @IBInspectable public var centerYOffset: CGFloat = 20.0
    @IBInspectable public var horizontalStretchingFactor: CGFloat = 1.5
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = [innerRadiusFraction, 1.0]
        let gradient = locations.withUnsafeBufferPointer { (ptr) in
            CGGradient(colorsSpace: colorSpace, colors: [innerColor.cgColor, outerColor.cgColor] as CFArray, locations: ptr.baseAddress!)!
        }
        let center = CGPoint(x: bounds.midX, y: bounds.midY + centerYOffset)
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: outerRadius, options: .drawsAfterEndLocation)
        layer.transform = CATransform3DScale(layer.transform, horizontalStretchingFactor, 1, 1)
    }

    

}
