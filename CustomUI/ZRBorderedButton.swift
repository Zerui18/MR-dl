//
//  ZRBorderedButton.swift
//  CustomUI
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

@IBDesignable
public class ZRBorderedButton: UIButton {
    
    @IBInspectable public var borderColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            self.layer.borderColor = isHighlighted ? titleColor(for: .highlighted)!.cgColor:self.borderColor.cgColor
        }
    }
}
