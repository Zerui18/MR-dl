//
//  NVActivityIndicatorAnimationDelegate.swift
//  CustomUI
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

protocol NVActivityIndicatorAnimationDelegate{
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor)
}
