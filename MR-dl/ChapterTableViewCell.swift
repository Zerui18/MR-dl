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

    var chapterMeta: MRSerieMeta.ChapterMeta!{
        didSet{
            titleLabel.text = chapterMeta.name
            lastUpdatedLabel.text = chapterMeta.lastUpdatedDescription
        }
    }
    var localChapter: MRChapter!{
        didSet{
            titleLabel.text = localChapter.name!
            lastUpdatedLabel.text = localChapter.lastUpdatedDescription
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
}
