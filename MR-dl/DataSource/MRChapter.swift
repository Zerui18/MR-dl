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

@objc(MRChapter)
class MRChapter: NSManagedObject{
    
    @objc var lastUpdatedDescription: String{
        return dateFormatter.string(from: dateUpdated!)
    }
    
    // copy meta infos, construct relationship, initialize directory
    convenience init(fromMeta meta: MRChapterMeta, serie: MRSerie, context: NSManagedObjectContext = .main) {
        self.init(entity: NSEntityDescription.entity(forEntityName: "MRChapter", in: context)!, insertInto: context)
        self.dateUpdated = meta.lastUpdated
        self.oid = meta.oid
        self.name = meta.name
        self.order = Int64(meta.order)
        serie.addToChapters(self)
        try! initDirectory()
    }
    
    lazy var directory: URL = {
        return serie!.directory.appendingPathComponent(String(order)+"/")
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
    
    func fetchImageURLs(completion:@escaping ([URL]?)->Void){
        MRClient.getChapterImageURLs(forOid: oid!) { (_, response) in
            if let urls = response?.data{
                self.remoteImageURLs = urls
                CoreDataHelper.shared.tryToSave()
            }
            completion(response?.data)
        }
    }
    
    func sortedLocalImageURLs()-> [URL]?{
        if let pages = remoteImageURLs{
            return [Int](0...pages.count-1).map(addressForPage)
        }
        return nil
    }
    
    lazy var downloader = MRChapterDownloader(chapter: self, maxConcurrentDownload: 16, delegate: serie!.downloader)
    
}

extension MRChapter{
    
    func addressForPage(atIndex index: Int)-> URL{
        return directory.appendingPathComponent("\(index).webp")
    }
    
    func hasDownloadedPage(ofIndex index: Int)-> Bool{
        return FileManager.default.fileExists(atPath: addressForPage(atIndex: index).path)
    }
        
}
