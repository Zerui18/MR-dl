//
//  ChapterDownloadsTableViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 28/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

class ChapterDownloadsTableViewController: UITableViewController {
    
    static func `init`(serie: MRSerie)-> ChapterDownloadsTableViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterDownloadsCtr") as! ChapterDownloadsTableViewController
        ctr.serie = serie
        return ctr
    }
    
    var serie: MRSerie!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }


}
