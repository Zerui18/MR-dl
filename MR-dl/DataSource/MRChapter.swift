//
//  MRChapter+Extensions.swift
//  MR-dl
//
//  Created by Chen Changheng on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import CoreData
import MRClient

fileprivate let jsonDecoder = JSONDecoder()
fileprivate let jsonEncoder = JSONEncoder()

@objc class MRChapter: NSManagedObject{
    
    var lastUpdatedDescription: String{
        return dateFormatter.string(from: dateUpdated!)
    }
    
    // copy meta infos, construct relationship, initialize directory
    convenience init(fromMeta meta: MRSerieMeta.ChapterMeta, serie: MRSerie, context: NSManagedObjectContext = .main) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "MRChapter", in: context)!, insertInto: context)
        self.dateUpdated = meta.updated
        self.oid = meta.oid
        self.name = meta.name
        serie.addToChapters(self)
        try! initDirectory()
    }
    
    lazy var directory: URL = {
        return serie!.directory.appendingPathComponent(String(order))
    }()
    
    private func initDirectory()throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
    }
    
    var remoteImageURLs: [URL]?{
        get{
            if _remoteImageURLs != nil{
                return _remoteImageURLs
            }
            else if let data = encodedImageURLs{
                return try? jsonDecoder.decode([URL].self, from: data)
            }
            return nil
        }
        set{
            if let newValue = newValue{
                encodedImageURLs = try! jsonEncoder.encode(newValue)
                _remoteImageURLs = newValue
            }
        }
    }
    private var _remoteImageURLs: [URL]?
    
    func sortedLocalImageURLs()-> [URL]?{
        if let pages = remoteImageURLs{
            return [Int](0...pages.count-1).map(addressForPage)
        }
        return nil
    }
    
    lazy var downloader: MRChapterDownloader? = MRChapterDownloader(chapter: self, maxConcurrentDownload: 4, delegate: self)
    var downloadProgress: Progress?
    
    enum DownloadState: Int16{case none=0, downloading, downloaded}
    var downloadState: DownloadState{
        get{
            return DownloadState(rawValue: downloadStateRaw)!
        }
        set{
            downloadStateRaw = newValue.rawValue
        }
    }
    
}

extension MRChapter{
    
    func addressForPage(atIndex index: Int)-> URL{
        return directory.appendingPathComponent("\(index).webp")
    }
    
    func hasDownloadedPage(ofIndex index: Int)-> Bool{
        return FileManager.default.fileExists(atPath: addressForPage(atIndex: index).path)
    }
    
}

extension MRChapter: MRChapterDownloaderDelegate{
    
    func downloaderDidInitiateDownload(forChapter chapter: MRChapter, withError error: Error?) {

    }
    
    func downloaderDidDownload(pageAtIndex index: Int, forChapter chapter: MRChapter, withError error: Error?) {
        
    }
    
}
