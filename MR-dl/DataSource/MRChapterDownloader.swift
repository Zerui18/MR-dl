//
//  MRImageDownloader.swift
//  MR-dl
//
//  Created by Chen Zerui on 24/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import ImageLoader

protocol MRChapterDownloaderDelegate: class{
    func downloaderDidInitiateDownload(forChapter chapter: MRChapter, withError error: Error?)
    func downloaderDidDownload(pageAtIndex index: Int, forChapter chapter: MRChapter, withError error: Error?)
    func downloaderDidComplete(chapter: MRChapter)
}

// downloader object in-charge of downloading single chapter
class MRChapterDownloader: NSObject{
    
    let chapter: MRChapter
    let maxConcurrentDownload: Int
    weak var delegate: MRChapterDownloaderDelegate?
    
    var urlSession: URLSession!
    var downloadsQueue: [URLSessionDownloadTask] = []
    var activeDownloads: [URL:URLSessionDownloadTask] = [:]
    var failedQueue: [URL] = []
    var urlToIndex: [URL:Int] = [:]
    
    var initialURLsToDownload: [URL]!
    
    // getter for private progress object, to ensure that initializeVariablesIfNecessary() has a chance to setup progress object if possible
    var progress: Progress{
        initializeVariablesIfNecessary()
        return _progress
    }
    
    // progress object linked to serie's download progress, with weight of 1
    lazy private var _progress: Progress = {
        return Progress(totalUnitCount: 999, parent: chapter.serie!.downloader.downloadProgress, pendingUnitCount: 1)
    }()
    
    // initializer
    init(chapter: MRChapter, maxConcurrentDownload: Int, delegate: MRChapterDownloaderDelegate){
        self.chapter = chapter
        self.delegate = delegate
        self.maxConcurrentDownload = maxConcurrentDownload
        super.init()
    }
    
    var downloadState: DownloadState{
        if progress.totalUnitCount == 999{
            return .none
        }
        return progress.isFinished ? .downloaded:.downloading
    }
    
    // initialize urls to download & update progress' total unit count if that's not done
    // call after chapter's remoteImageURLs are fetched when possible
    func initializeVariablesIfNecessary(){
        // progress's total unit count is not placeholder value, already initialized
        if _progress.totalUnitCount != 999{
            return
        }
        // set initialURLsToDownload to urls that have yet to be downloaded
        guard let imageURLs = chapter.remoteImageURLs else{
            return
        }
        urlToIndex = Dictionary(uniqueKeysWithValues: imageURLs.enumerated().map{($0.1, $0.0)})
        _progress.totalUnitCount = Int64(imageURLs.count)
        for (index, url) in imageURLs.enumerated(){
            if !chapter.hasDownloadedPage(ofIndex: index){
                initialURLsToDownload.append(url)
            }
            else{
                _progress.completedUnitCount += 1
            }
        }
    }
    
    // convenience function for starting download for the chapter
    func beginDownload(){
        // ignore call if currently downloading || fully downloaded
        if !activeDownloads.isEmpty{
            return
        }
        if downloadState == .downloaded{
            return
        }
        failedQueue.removeAll()
        urlToIndex.removeAll()
        downloadsQueue.removeAll()
        if chapter.remoteImageURLs != nil{
            _beginDownload()
        }
        else{
            chapter.fetchImageURLs{[weak self] error in
                guard let strongSelf = self else{
                    return
                }
                if error == nil{
                    strongSelf.initializeVariablesIfNecessary()
                    strongSelf._beginDownload()
                }
                strongSelf.delegate?.downloaderDidInitiateDownload(forChapter: strongSelf.chapter, withError: error)
            }
        }
    }
    
    // initialize urlsession data tasks & local progress object
    private func _beginDownload(){
        if urlSession == nil{
            urlSession = URLSession(configuration: .background(withIdentifier: "mrchapterdownloader-"+chapter.oid!), delegate: self, delegateQueue: nil)
        }
        initiateDownloadTasks(forURLs: initialURLsToDownload)
    }
    
    // create download tasks for the given urls & add them to queue
    private func initiateDownloadTasks(forURLs urls: [URL]){
        for url in urls{
            let downloadTask = urlSession.downloadTask(with: url)
            addToQueue(downloadTask: downloadTask)
        }
    }
    
    // distribute tasks to queue such that there's at most maxConcurrentDownload tasks active
    private func addToQueue(downloadTask: URLSessionDownloadTask){
        if activeDownloads.count < maxConcurrentDownload{
            startTask(downloadTask)
        }
        else{
            downloadsQueue.append(downloadTask)
        }
    }
    
    // start task and record it in activeDownloads
    private func startTask(_ downloadTask: URLSessionDownloadTask){
        activeDownloads[downloadTask.originalRequest!.url!] = downloadTask
        downloadTask.resume()
    }
    
    // start next task in queue & returns if a new task has been started
    private func startNextPendingTaskIfNecessary()-> Bool{
        if let nextTask = downloadsQueue.dropFirst().first{
            startTask(nextTask)
            return true
        }
        return false
    }
    
    // restarts all & removes tasks from failedTasks
    func retryFailedTasks(){
        if urlSession == nil{
            urlSession = URLSession(configuration: .background(withIdentifier: "mrchapterdownloader-"+chapter.oid!), delegate: self, delegateQueue: nil)
        }
        initiateDownloadTasks(forURLs: failedQueue)
        failedQueue.removeAll()
    }
    
    // convenience function for cancelling download for the chapter
    func cancelDownload(){
        downloadsQueue.removeAll()
        activeDownloads.removeAll()
        // url session will be reset anyway
        urlSession.invalidateAndCancel()
        urlSession = nil
    }

}

extension MRChapterDownloader: URLSessionDownloadDelegate{
    
    // only called when download task completes successfully, vanila implementation assumes everything will go as planned...
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // decrypt & 'move' webp-image data from download location to permanent location
        let pageIndex = urlToIndex[downloadTask.originalRequest!.url!]!
        let data = try! Data(contentsOf: location)
        let decryptedData = MRImageDataDecryptor.decrypt(data: data)
        try! decryptedData.write(to: chapter.addressForPage(atIndex: pageIndex))
        // update progress
        _progress.completedUnitCount += 1
        try? FileManager.default.removeItem(at: location)
    }
    
    // called at the end of each task, here we remove the task from queue (add it to failed queue if...), start next task in queue & notifiy delegate about task completion
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let pageIndex = urlToIndex[task.originalRequest!.url!]!
        activeDownloads.removeValue(forKey: task.originalRequest!.url!)
        if error != nil{
            failedQueue.append(task.originalRequest!.url!)
        }
        delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: error)
        if !startNextPendingTaskIfNecessary() && activeDownloads.isEmpty{
            delegate?.downloaderDidComplete(chapter: chapter)
        }
    }
    
}

