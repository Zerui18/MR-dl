//
//  UIView+Extensions.swift
//  CustomUI
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

public extension UIView{
    
    public var parentViewController: UIViewController?{
        var parentResponder: UIResponder? = self
        while parentResponder != nil{
            parentResponder = parentResponder!.next
            if parentResponder! is UIViewController{
                break
            }
        }
        return parentResponder as? UIViewController
    }
    
}
