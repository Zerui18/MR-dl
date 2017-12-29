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
    var urlToIndex: [URL:Int] = [:]
    
    var urlsToDownload = [URL]()
    
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
    }
    
    
    var state: DownloadState{
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
        if !activeDownloads.isEmpty{
            return
        }
        if state == .downloaded{
            return
        }
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
        // check if image has already been cached
        if let cachedImage = Manager.sharedMRImageManager.cachedImage(for: Request(url: key)){
            let pageIndex = urlToIndex[key]!
            try! UIImageJPEGRepresentation(cachedImage, 1.0)!.write(to: chapter.addressForPage(atIndex: pageIndex))
            // already downloaded, report completion directly
            downloadedPage(at: pageIndex, withError: nil)
        }
        else{
            // record task in activeDownloads & startTask
            activeDownloads[key] = downloadTask
            downloadTask.resume()
        }
    }
    
    // start next task in queue & returns if a new task has been started
    private func startNextPendingTaskIfNecessary()-> Bool{
        if !downloadsQueue.isEmpty{
            startTask(downloadsQueue.removeFirst())
            return true
        }
        return false
    }
    
    // convenience function for cancelling download for the chapter
    func cancelDownload(){
        if state != .downloading{
            return
        }
        print("cancel download called")
        downloadsQueue.removeAll()
        activeDownloads.removeAll()
        // url session will be reset anyway
        if urlSession != nil{
            urlSession.invalidateAndCancel()
            urlSession = nil
        }
    }
    
    
    func downloadedPage(at pageIndex: Int, withError error: Error?){
        // stop downloader immediately when any page fails to download
        if error != nil{
            delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: error)
            cancelDownload()
            return
        }
        else{
            // update progress， then notify delegate
            _progress.completedUnitCount += 1
            delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: error)
        }
        // if no more queing & outstanding tasks, notify delegate of completion (note: some pages might failed to download)
        if !startNextPendingTaskIfNecessary() && activeDownloads.isEmpty{
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
            let data = try Data(contentsOf: location)
            let image = UIImage(mriData: data)!
            try! UIImageJPEGRepresentation(image, 1.0)!.write(to: chapter.addressForPage(atIndex: pageIndex))
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
            activeDownloads.removeValue(forKey: task.originalRequest!.url!)
            let pageIndex = urlToIndex[task.originalRequest!.url!]!
            downloadedPage(at: pageIndex, withError: error)
        }
        // else didFinishDownloadingTo would have called the above
    }
    
}

