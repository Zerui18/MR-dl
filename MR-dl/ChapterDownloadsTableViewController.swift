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
        navigationItem.title = "\(serie.chaptersCount) Chapters"
        tableView.tableFooterView = UIView()
        serie.downloader.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
}


extension ChapterDownloadsTableViewController{
    // sections: downloaded, downloading
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return serie.downloader.downloadedChapters.count
        }
        else{
            return serie.downloader.downloadingChapters.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: ChapterTableViewCell.identifier) as! ChapterTableViewCell
            cell.localChapter = serie.downloader.downloadedChapters[indexPath.row]
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ChapterDownloadTableViewCell.identifier) as! ChapterDownloadTableViewCell
            cell.chapter = serie.downloader.downloadingChapters[indexPath.row]
            return cell
        }
    }

    // incomplete implementation!!
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            return nil
        }
        // is first in download queue
        if serie.downloader.downloadingChapters[indexPath.row].downloader.state == .downloading{
            return UISwipeActionsConfiguration(actions: [UIContextualAction.init(style: .destructive, title: "Pause", handler: { (_, _, completion) in
                self.serie.downloader.cancelDownload()
                completion(true)
            })])
        }
        let beginAction = UIContextualAction(style: .normal, title: "Download") { (_, _, completion) in
            self.serie.downloader.beginDownload(forIndex: indexPath.row)
            self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
            completion(true)
        }
        beginAction.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.6647321429, blue: 1, alpha: 1)
        return UISwipeActionsConfiguration(actions: [beginAction])
    }

}

extension ChapterDownloadsTableViewController: MRSerieDownloaderDelegate{
    
    // reload row to reflect progress change
    // TODO: use visible-only reload
    func downloaderDidDownload(chapter: MRChapter, page: Int, error: Error?) {
        if let index = serie.downloader.downloadingChapters.index(of: chapter){
            // sync to block current thread from modifying data before ui change is applied
            DispatchQueue.main.sync {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
            }
        }
    }
    
    // 'move' row from downloading section (1) to downloaded section (0)
    func downloaderDidComplete(chapter: MRChapter, originalIndex: Int) {
        if let index = serie.downloader.downloadedChapters.index(of: chapter){
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: originalIndex, section: 1)], with: .automatic)
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    
}
