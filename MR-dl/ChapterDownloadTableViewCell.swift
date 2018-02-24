//
//  ChapterDownloadTableViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 28/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

class ChapterDownloadTableViewCell: UITableViewCell {

    static let identifier = "chapterDownloadCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stateLabel: UILabel!
    
    
    var chapter: MRChapter! {
        didSet {
            titleLabel.text = chapter.name
            progressView.progress = Float(chapter.downloader.progress.fractionCompleted)
            stateLabel.text = chapter.downloader.progress.descriptionInUnit
        }
    }

}
