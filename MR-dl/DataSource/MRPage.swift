//
//  MRPage.swift
//  MR-dl
//
//  Created by Chen Zerui on 24/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import CoreData
import MRClient
import MRImageLoader

@objc class MRPage: NSManagedObject{
    
    convenience init(downloadURL: URL, context: NSManagedObjectContext) {
        self.init(context: context)
        self.downloadURL = downloadURL
    }
    
    var activeDownloadTask: URLSessionDownloadTask?
    
}

extension MRPage{
    
    enum DownloadState{
        case none, downloading, downloaded
    }
    
    var downloadState: DownloadState{
        if webPData != nil{
            return .downloaded
        }
        return activeDownloadTask != nil ? .downloading:.none
    }
    
    func startDownloadin(){
        if downloadState != .downloading{
            
        }
    }
    
    private func _startDownloading(){

    }
    
}
