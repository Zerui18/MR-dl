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
    
    var progress: Progress?
    
    init(chapter: MRChapter, maxConcurrentDownload: Int, delegate: MRChapterDownloaderDelegate){
        self.chapter = chapter
        self.delegate = delegate
        self.maxConcurrentDownload = maxConcurrentDownload
        super.init()
    }
    
    // convenience function for starting download for the chapter
    func beginDownload(){
        if progress != nil{
            return
        }
        if chapter.remoteImageURLs != nil{
            _beginDownload()
        }
        else{
            MRClient.getChapterImageURLs(forOid: chapter.oid!) {[weak self] (error, response) in
                guard let weakSelf = self else{
                    return
                }
                if let urls = response?.data{
                    weakSelf.chapter.remoteImageURLs = urls
                    weakSelf._beginDownload()
                }
                weakSelf.delegate?.downloaderDidInitiateDownload(forChapter: weakSelf.chapter, withError: error)
            }
        }
    }
    
    private func _beginDownload(){
        progress = Progress(totalUnitCount: Int64(chapter.remoteImageURLs!.count))
        if urlSession == nil{
            urlSession = URLSession(configuration: .background(withIdentifier: "mrchapterdownloader-"+chapter.oid!), delegate: self, delegateQueue: nil)
        }
        let imageURLs = chapter.remoteImageURLs!
        urlToIndex = Dictionary(uniqueKeysWithValues: imageURLs.enumerated().map{($0.1, $0.0)})
        var urlsToDownload = [URL]()
        let activeDownloads = self.activeDownloads.keys
        for (index, url) in imageURLs.enumerated(){
            if !chapter.hasDownloadedPage(ofIndex: index) && !activeDownloads.contains(url){
                urlsToDownload.append(url)
            }
        }
        initiateDownloadTasks(forURLs: urlsToDownload)
    }
    
    private func initiateDownloadTasks(forURLs urls: [URL]){
        for url in urls{
            let downloadTask = urlSession.downloadTask(with: url)
            addToQueue(downloadTask: downloadTask)
        }
    }
    
    private func addToQueue(downloadTask: URLSessionDownloadTask){
        if downloadsQueue.count < maxConcurrentDownload{
            startTask(downloadTask)
        }
        else{
            downloadsQueue.append(downloadTask)
        }
    }
    
    private func startTask(_ downloadTask: URLSessionDownloadTask){
        activeDownloads[downloadTask.originalRequest!.url!] = downloadTask
        downloadTask.resume()
    }
    
    // convenience function for cancelling download for the chapter
    func cancelDownload(){
        urlSession.invalidateAndCancel()
        urlSession = nil
    }

}

extension MRChapterDownloader: URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let pageIndex = urlToIndex[downloadTask.originalRequest!.url!]!
        if let data = try? Data(contentsOf: location), data.count > 0{
            let decryptedData = MRImageDataDecryptor.decrypt(data: data)
            try! decryptedData.write(to: chapter.addressForPage(atIndex: pageIndex))
        }
        try? FileManager.default.removeItem(at: location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let pageIndex = urlToIndex[task.originalRequest!.url!]!
        activeDownloads.removeValue(forKey: task.originalRequest!.url!)
        if !downloadsQueue.isEmpty{
            startTask(downloadsQueue.removeFirst())
        }
        delegate?.downloaderDidDownload(pageAtIndex: pageIndex, forChapter: chapter, withError: error)
    }
    
}

