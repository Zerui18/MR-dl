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
    
    var chaptersCount: Int {
        return isLocalSource ? localSerie!.downloader.downloadedChapters.count:serieMeta.chapters.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        tableView.tableFooterView = UIView()
        navigationItem.title = "\(chaptersCount) Chapters"
        localSerie?.downloader.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            cell.localChapter = localSerie!.downloader.downloadedChapters[indexPath.row]
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

extension ChaptersTableViewController: MRSerieDownloaderDelegate{
    
    // add downloaded chapter to list of 'readable' chapters
    func downloaderDidComplete(chapter: MRChapter, originalIndex: Int) {
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: self.localSerie!.downloader.downloadedChapters.index(of: chapter)!, section: 0)], with: .automatic)
        }
    }
    
    func downloaderDidDownload(chapter: MRChapter, page: Int, error: Error?) {
        // nothing to be done here
    }
    
}
