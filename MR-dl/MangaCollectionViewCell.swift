//
//  SerieCollectionViewCell.swift
//  MR-dl
//
//  Created by Chen Changheng on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI

class SerieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "serieItem"
    
    @IBOutlet weak var coverImageView: ZRImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
