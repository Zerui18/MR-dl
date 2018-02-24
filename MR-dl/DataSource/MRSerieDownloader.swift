//
//  MRSerieDownloader.swift
//  MR-dl
//
//  Created by Chen Zerui on 27/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

protocol MRSerieDownloaderDelegate: class {
    func downloaderDidDownload(chapter: MRChapter, page: Int, error: Error?)
    func downloaderDidComplete(chapter: MRChapter, originalIndex: Int)
}

class MRSerieDownloader {
    
    weak var delegate: MRSerieDownloaderDelegate?
    
    let serie: MRSerie
    let progress: Progress
    var isFullyDownloaded: Bool {
        return progress.isFinished
    }
    
    // all fully-downloaded chapters
    var downloadedChapters = [MRChapter]()
    // all non-fully downloaded chapters
    var notDownloadedChapters = [MRChapter]()
    
    // temporary variable to keep track if the current download was cancelled
    var isCancelled = false
    
    init(serie: MRSerie) {
        self.serie = serie
        let allChapters = serie.chaptersAsArray()
        // initialize progress
        self.progress = Progress(totalUnitCount: Int64(allChapters.count))
        // new hack to prevent circular reference
        serie.downloader = self
        
        for chapter in allChapters {
            if chapter.downloader.state == .downloaded {
                downloadedChapters.append(chapter)
                progress.completedUnitCount += 1
            }
            else {
                notDownloadedChapters.append(chapter)
            }
        }
    }

    // add chapter to download queue (when serie is refreshed with the downloader already initialized)
    func addChapter(_ chapter: MRChapter) {
        progress.totalUnitCount += 1
        if chapter.downloader.state == .downloaded {
            downloadedChapters.append(chapter)
            progress.completedUnitCount += 1
        }
        else {
            notDownloadedChapters.append(chapter)
        }
    }

    // begin downloading (in series) the downloadingChapters
    func beginDownload() {
        isCancelled = false
        notDownloadedChapters.first?.downloader.beginDownload()
    }
    
    // cancel download for current-downloading chapter and begin downloading the chapter at the specifed index in the downloadingChapters array
    func beginDownload(forIndex index: Int) {
        cancelDownload()
        notDownloadedChapters.insert(notDownloadedChapters.remove(at: index), at: 0)
        beginDownload()
    }
    
    // cancel download for the current-downloadin chapter (if applicable), then post notification regarding this cancellation event
    func cancelDownload() {
        if let firstChapter = notDownloadedChapters.first {
            isCancelled = true
            firstChapter.downloader.cancelDownload()
        }
    }
    
}

extension MRSerieDownloader: MRChapterDownloaderDelegate {

    func downloaderDidDownload(pageAtIndex index: Int, forChapter chapter: MRChapter, withError error: Error?) {
        if error == nil {
            // no error, update delegate about progress
            delegate?.downloaderDidDownload(chapter: chapter, page: index, error: error)
        }
    }
    
    // on chapter downloader tasks complete, remove it from downloading list & add it back to queue if not fully downloaded, also update downloaded/downloading chapters list
    func downloaderDidComplete(chapter: MRChapter) {
        // do not perform any action if function called due to download cancellation
        // additionally check if chapter's already downloaded -> ignore cancellation and continue to update UI
        guard chapter.downloader.state == .downloaded else {
            // chapter failed to download, cancel all pending chapter downloads
            if !isCancelled {
                cancelDownload()
            }
            return
        }
        // download successful, update all related arrays & start downloading next chapter
        guard let originalIndex = notDownloadedChapters.index(of: chapter) else {
            return
        }
        notDownloadedChapters.remove(at: originalIndex)
        downloadedChapters.append(chapter)
        downloadedChapters.sortUsingProperty(atKeypath: \.order)
        delegate?.downloaderDidComplete(chapter: chapter, originalIndex: originalIndex)
        if let nextTask = notDownloadedChapters.first?.downloader {
            nextTask.beginDownload()
        }
//        else {
//            // all download completed, notify serie download completion
//
//        }
    }

}
