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
    
    // copy meta infos, construct relationship, initialize directory
    convenience init(fromMeta meta: MRSerieMeta.ChapterMeta, serie: MRSerie, context: NSManagedObjectContext = .shared) {
        self.init(context: context)
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
    
    var imageURLs: [URL]?{
        get{
            if _imageURLs != nil{
                return _imageURLs
            }
            else if let data = encodedImageURLs{
                return try? jsonDecoder.decode([URL].self, from: data)
            }
            return nil
        }
        set{
            if let newValue = newValue{
                encodedImageURLs = try! jsonEncoder.encode(newValue)
                _imageURLs = newValue
            }
        }
    }
    var _imageURLs: [URL]?
    
    lazy var downloader: MRChapterDownloader = MRChapterDownloader(chapter: self, maxConcurrentDownload: 4, delegate: self)
    
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
