//
//  ChapterTableViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import MRClient

class ChapterTableViewCell: UITableViewCell {
    
    static let identifier = "chapterCell"

    var chapter: MRSerieMeta.ChapterMeta!{
        didSet{
            titleLabel.text = chapter.name
            lastUpdatedLabel.text = chapter.lastUpdatedDescription
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
}
