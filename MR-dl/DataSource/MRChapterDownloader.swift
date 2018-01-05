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
    var urlToIndex: [URL:Int] = [:]
    
    var urlsToDownload = [URL]()
    var isDownloading: Bool{
        return !activeDownloads.isEmpty
    }
    // no UI to update so not using this
//    var backgroundCompletionHandler: (()->Void)?
    
    // getter for private progress object, to ensure that initializeVariablesIfNecessary() has a chance to setup progress object if possible
    var progress: Progress{
        initializeVariablesIfNecessary()
        return _progress
    }
    
    // progress object linked to serie's download progress, with weight of 1
    lazy private var _progress: Progress = {
        return Progress(totalUnitCount: 999, parent: chapter.serie!.downloader.progress, pendingUnitCount: 1)
    }()
    
    // initializer
    init(chapter: MRChapter, maxConcurrentDownload: Int, delegate: MRChapterDownloaderDelegate){
        self.chapter = chapter
        self.maxConcurrentDownload = maxConcurrentDownload
        self.delegate = delegate
        super.init()
        self.urlSession = URLSession(configuration: .background(withIdentifier: chapter.serie!.oid!+"-"+chapter.oid!), delegate: self, delegateQueue: nil)
    }
    
    
    var state: DownloadState{
        if progress.totalUnitCount == 999{
            return .notDownloaded
        }
        return progress.isFinished ? .downloaded:.notDownloaded
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
                urlsToDownload.append(url)
            }
            else{
                _progress.completedUnitCount += 1
            }
        }
    }
    
    // convenience function for starting download for the chapter
    func beginDownload(){
        // ignore call if currently downloading || fully downloaded
        if isDownloading{
            return
        }
        if state == .downloaded{
            return
        }
        if chapter.remoteImageURLs != nil{
            _beginDownload()
        }
        else{
            chapter.fetchImageURLs{[weak self] urls in
                guard let strongSelf = self else{
                    return
                }
                if urls != nil{
                    strongSelf.initializeVariablesIfNecessary()
                    strongSelf._beginDownload()
                }
            }
        }
    }
    
    // initialize urlsession data tasks & local progress object
    private func _beginDownload(){
        isCancelled = false
        if urlSession == nil{
            urlSession = URLSession(configuration: .background(withIdentifier: chapter.serie!.oid!+"-"+chapter.oid!), delegate: self, delegateQueue: nil)
        }
        initiateDownloadTasks(forURLs: urlsToDownload)
    }
    
    // create download tasks for the given urls & add them to queue
    private func initiateDownloadTasks(forURLs urls: [URL]){
        for task in urls.map(self.urlSession.downloadTask){
            addToQueue(downloadTask: task)
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
        let key = downloadTask.originalRequest!.url!
        // record task in activeDownloads & startTask
        activeDownloads[key] = downloadTask
        downloadTask.resume()
        // check if image has already been cached
//        if let cachedImage = Manager.sharedMRImageManager.cachedImage(for: Request(url: key)){
//            let pageIndex = urlToIndex[key]!
//            let webpData = MRImageDataDecryptor.decrypt(data: try Data(contentsOf: location))
//            try webpData.write(to: chapter.addressForPage(atIndex: pageIndex))
//            // already downloaded, report completion directly
//            downloadedPage(at: pageIndex, withError: nil)
//        }
//        else{
//            // record task in activeDownloads & startTask
//            activeDownloads[key] = downloadTask
//            downloadTask.resume()
//        }
    }
    
    // start next task in queue & returns if a new task has been started
    private func startNextPendingTaskIfNecessary()-> Bool{
        if !downloadsQueue.isEmpty{
            startTask(downloadsQueue.removeFirst())
            return true
        }
        return false
    }
    
    // indicating whether downloader is cancelled
    private var isCancelled = false
    
    // convenience function for cancelling download for the chapter
    func cancelDownload(){
        isCancelled = true
        downloadsQueue.forEach{
            $0.cancel()
        }
        activeDownloads.values.forEach{
            $0.cancel()
        }
        downloadsQueue.removeAll()
        activeDownloads.removeAll()
    }
    
    
    func downloadedPage(at pageIndex: Int, withError error: Error?){
        // stop downloader immediately when any page fails to download
        if error != nil{
            delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: error)
            // error not due to task cancelled, cancel all other tasks
            if !isCancelled{
                cancelDownload()
            }
            return
        }
        else{
            // update progress， then notify delegate
            _progress.completedUnitCount += 1
            delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: nil)
        }
        // if no more queing & outstanding tasks, notify delegate of completion (note: some pages might failed to download)
        if !startNextPendingTaskIfNecessary() && state == .downloaded{
            delegate?.downloaderDidComplete(chapter: chapter)
        }
    }

}


extension MRChapterDownloader: URLSessionDownloadDelegate{
    
    // only called when download task completes successfully
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // decrypt, decode, move image data from download location to permanent location
        let key = downloadTask.originalRequest!.url!
        let pageIndex = urlToIndex[key]!
        activeDownloads.removeValue(forKey: key)
        do{
            let webpData = MRImageDataDecryptor.decrypt(data: try Data(contentsOf: location))
            try webpData.write(to: chapter.addressForPage(atIndex: pageIndex))
            try? FileManager.default.removeItem(at: location)
            urlsToDownload.delete(key)
            downloadedPage(at: pageIndex, withError: nil)
        }
        catch{
            downloadedPage(at: pageIndex, withError: error)
        }
    }
    
    // called at the end of each task, only perform variables update & delegate call if error is caught here
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil{
            self.activeDownloads.removeValue(forKey: task.originalRequest!.url!)
            let pageIndex = self.urlToIndex[task.originalRequest!.url!]!
            self.downloadedPage(at: pageIndex, withError: error)
        }
        // else didFinishDownloadingTo would have called the above
    }
    
}

