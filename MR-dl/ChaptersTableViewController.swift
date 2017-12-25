//
//  ChaptersTableViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import MRClient

class ChaptersTableViewController: UITableViewController {
    
    static func `init`(withSerieMeta meta: MRSerieMeta)-> ChaptersTableViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chaptersTableCtr") as! ChaptersTableViewController
        ctr.serieMeta = meta
        return ctr
    }
    
    var serieMeta: MRSerieMeta!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.title = "\(serieMeta.chapters.count) Chapters"
        navigationController?.hidesBarsOnSwipe = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.isNavBarTransparent = false
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        })
        self.isNavBarTransparent = false
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serieMeta.chapters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChapterTableViewCell.identifier) as! ChapterTableViewCell
        cell.chapter = serieMeta.chapters[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewChapterCtr = ChapterImagesPageViewController(forSerie: serieMeta, atChapter: indexPath.row)
        navigationController?.pushViewController(viewChapterCtr, animated: true)
    }
    
}
