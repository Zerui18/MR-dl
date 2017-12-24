//
//  MRImageDownloader.swift
//  MR-dl
//
//  Created by Chen Zerui on 24/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import MRImageLoader

class MRChapterDownloader: NSObject{
    
    var urlSession: URLSession!
    var chaptersDownloading = [MRChapter]()
    
    override init(){
        super.init()
        urlSession = URLSession(configuration: .background(withIdentifier: "mrchapterdownloader"), delegate: self, delegateQueue: nil)
    }
    
    func download(chapter: MRChapter){
        
    }
    
}

extension MRChapterDownloader: URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError?{
            if error.code == NSURLErrorCancelled{
                
            }
            else{
                
            }
        }
    }
    
}
