//
//  UITableView+Extension.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var indexPath: IndexPath? {
        return (superview as! UITableView).indexPath(for: self)
    }
}

extension UITableView {
    
    func visibleCell(forIndexPath indexPath: IndexPath)-> UITableViewCell? {
        return visibleCells.first {
            $0.indexPath == indexPath
        }
    }
    
}
