//
//  ArtworkCollectionViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI

class ArtworkCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "artworkItem"
    
    @IBOutlet weak var imageView: ReactiveThumbnailView!
    
    var artworkURL: URL!{
        didSet{
            imageView.image = nil
            imageView.loadImage(fromURL: artworkURL)
        }
    }
    
}
