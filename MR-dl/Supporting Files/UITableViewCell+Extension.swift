//
//  UITableViewCell+Extension.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

fileprivate var indexPathAssociationKey = 1

extension UITableViewCell{
    
    var indexPath: IndexPath?{
        get{
            return objc_getAssociatedObject(self, &indexPathAssociationKey) as? IndexPath
        }
        set{
            objc_setAssociatedObject(self, &indexPathAssociationKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
}
