//
//  MangaTableViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import MRClient

class SerieTableViewCell: UITableViewCell {

    static let identifier = "serieCell"

    @IBOutlet weak var thumbnailImageView: ZRReactiveImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    var oid: String = "placeholder"{
        didSet{
            thumbnailImageView.image = nil
            titleLabel.text = nil
            statusLabel.text = nil
            lastUpdatedLabel.text = nil
            shortDescriptionLabel.text = nil
            
            fetchSerieMeta()
        }
    }
    
    func fetchSerieMeta(){
        MRClient.getSerieMeta(forOid: oid) {[weak self] (error, response) in
            if let `self` = self, let serieMeta = response?.data, serieMeta.oid == self.oid{
                DispatchQueue.main.async {
                    self.serieMeta = serieMeta
                }
            }
        }
    }
    
    var shortMeta: MRShortMeta?{
        didSet{
            if let meta = shortMeta{
                titleLabel.text = meta.name
                thumbnailImageView.loadImage(withLoader: ThumbnailLoader.shared, fromURL: meta.thumbnailURL!)
            }
        }
    }

    var serieMeta: MRSerieMeta?{
        didSet{
            if let meta = serieMeta{
                statusLabel.text = meta.statusDescription
                lastUpdatedLabel.text = meta.lastUpdatedDescription
                shortDescriptionLabel.text = meta.serieDescription
            }
        }
    }
    
    
}
