//
//  MRSerieDownloader.swift
//  MR-dl
//
//  Created by Chen Zerui on 27/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

class MRSerieDownloader{
    
    let serie: MRSerie
    let downloadProgress: Progress
    let maxConcurrent: Int
    var isDownloaded: Bool{
        return downloadProgress.isFinished
    }
    
    var serieChapters: [MRChapter]{
        return serie.chapters!.array as! [MRChapter]
    }
    
    init(serie: MRSerie, maxConcurrent: Int = 2){
        self.serie = serie
        self.downloadProgress = Progress(totalUnitCount: Int64(serie.chapters!.count))
        self.maxConcurrent = maxConcurrent
        self.downloadProgress.completedUnitCount = Int64(serieChapters.count{$0.downloader.downloadState == .downloaded})
    }
    
    private var downloadingChapters: [MRChapter] = []
    private var queuingChapters: [MRChapter] = []
    
    func beginDownload(){
        for chapter in serieChapters{
            chapter.downloader.beginDownload()
        }
    }
    
    private func addToQueue(_ chapter: MRChapter){
        if downloadingChapters.count < maxConcurrent{
            downloadingChapters.append(chapter)
            chapter.downloader.beginDownload()
        }
        else{
            queuingChapters.append(chapter)
        }
    }
    
    func pauseDownload(){
        for chapter in serieChapters{
            chapter.downloader.cancelDownload()
        }
    }
    
    func resumeDownload(){
        for chapter in serieChapters{
            chapter.downloader.retryFailedTasks()
        }
    }
    
}

extension MRSerieDownloader: MRChapterDownloaderDelegate{
    
    func downloaderDidInitiateDownload(forChapter chapter: MRChapter, withError error: Error?) {
        // currently noting to be done here...
    }
    
    func downloaderDidDownload(pageAtIndex index: Int, forChapter chapter: MRChapter, withError error: Error?) {
        
    }
    
    // on chapter downloader tasks complete, remove it from downloading list & add it back to queue if not fully downloaded
    func downloaderDidComplete(chapter: MRChapter) {
        downloadingChapters.delete(chapter)
        if chapter.downloader.downloadState != .downloaded{
            addToQueue(chapter)
        }
    }
    
}
