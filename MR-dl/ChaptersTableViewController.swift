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
    
    static func `init`(withSerie serie: MRSerie)-> ChaptersTableViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chaptersTableCtr") as! ChaptersTableViewController
        ctr.localSerie = serie
        return ctr
    }
    
    var serieMeta: MRSerieMeta!
    var localSerie: MRSerie?
    
    var isLocalSource: Bool{
        return localSerie != nil
    }
    
    lazy var chaptersCount: Int = {
        return isLocalSource ? localSerie!.chapters!.count:serieMeta.chapters.count
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        tableView.tableFooterView = UIView()
        navigationItem.title = "\(chaptersCount) Chapters"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.isNavBarTransparent = false
            self.statusBarStyle = .default
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        })
        self.isNavBarTransparent = false
        self.statusBarStyle = .default
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chaptersCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChapterTableViewCell.identifier) as! ChapterTableViewCell
        if isLocalSource{
            cell.localChapter = localSerie!.chapters![indexPath.row] as! MRChapter
        }
        else{
            cell.chapterMeta = serieMeta.chapters[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewChapterCtr: ChapterImagesPageViewController
        if isLocalSource{
            viewChapterCtr = ChapterImagesPageViewController.init(forLocalSerie: localSerie!, atChapter: indexPath.row)
        }
        else{
            viewChapterCtr = ChapterImagesPageViewController(forSerie: serieMeta, atChapter: indexPath.row)
        }
        navigationController?.pushViewController(viewChapterCtr, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
