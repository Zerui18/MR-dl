//
//  MarginedLabel.swift
//  CustomUI
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

@IBDesignable
public class ZRMarginedLabel: UILabel{
    
    @IBInspectable public var topMargin: CGFloat = 8.0
    @IBInspectable public var bottomMargin: CGFloat = 8.0
    @IBInspectable public var leftMargin: CGFloat = 8.0
    @IBInspectable public var rightMargin: CGFloat = 8.0
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override public func drawText(in rect: CGRect) {
        let newRect = CGRect(x: rect.minX + leftMargin, y: rect.minY + topMargin, width: rect.width - rightMargin - leftMargin, height: rect.height - bottomMargin - topMargin)
        super.drawText(in: newRect)
    }
    
}
