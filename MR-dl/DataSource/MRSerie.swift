//
//  MRSerie+Extensions.swift
//  MR-dl
//
//  Created by Chen Changheng on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import CoreData

let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let seriesDirectory = documentsDirectory.appendingPathComponent("Series")

fileprivate let jsonDecoder = JSONDecoder()
fileprivate let jsonEncoder = JSONEncoder()

let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd MMM yyyy"
    return f
}()

@objc class MRSerie: NSManagedObject{
    
    var statusDescription: String{
        return (completed ? "Completed, ":"Ongoing, ") + "\(chapters!.count) chapters"
    }
    
    var lastUpdatedDescription: String{
        return dateFormatter.string(from: lastUpdated!)
    }
    
    // copy meta infos, initialize empty chapters & directory
    convenience init(fromMeta meta: MRSerieMeta, context: NSManagedObjectContext = .main)throws {
        self.init(entity: NSEntityDescription.entity(forEntityName: "MRSerie", in: context)!, insertInto: context)
        self.name = meta.name
        self.thumbnailURL = meta.thumbnailURL
        self.oid = meta.oid
        self.author = meta.author
        self.artworkURLs = meta.artworkURLs
        self.chapters = NSOrderedSet()
        try initDirectory()
    }
    
    
    private func initDirectory()throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }
    
    lazy var directory: URL = {
        return seriesDirectory.appendingPathComponent(oid!)
    }()
    
    var artworkURLs: [URL]?{
        get{
            if _artworkURLs != nil{
                return _artworkURLs
            }
            else if let data = encodedArtworkURLs{
                return try? jsonDecoder.decode([URL].self, from: data)
            }
            return nil
        }
        set{
            if let newValue = newValue{
                encodedArtworkURLs = try! jsonEncoder.encode(newValue)
                _artworkURLs = newValue
            }
        }
    }
    var _artworkURLs: [URL]?
    
    func updateInfo(withMeta meta: MRSerieMeta){
        self.chaptersCount = Int64(meta.chaptersCount)
        self.completed = meta.completed
        let startIndex = chapters!.count
        let newChapterMetas = meta.chapters.suffix(from: startIndex)
        for meta in newChapterMetas{
            _ = MRChapter(fromMeta: meta, serie: self)
        }
    }
    
    func chaptersToDownload()-> [MRChapter]{
        return (chapters!.array as! [MRChapter]).filter{$0.downloadState != .downloaded}
    }
    
    func downloadChapterImages(){
        chaptersToDownload().forEach{
            $0.downloader?.beginDownload()
        }
    }
    
}
