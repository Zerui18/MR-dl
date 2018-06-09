//
//  String+Extensions.swift
//  MR-dl
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

extension String {
    
    func height(forWidth width: CGFloat, font: UIFont)-> CGFloat {
        let constrainedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = (self as NSString).boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
}
