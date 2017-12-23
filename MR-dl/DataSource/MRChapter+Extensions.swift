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

extension MRChapter{
    
    convenience init(fromMeta meta: MRSerieMeta.ChapterMeta, serie: MRSerie, context: NSManagedObjectContext) {
        self.init(context: context)
        self.dateUpdated = meta.updated
        self.oid = meta.oid
        self.name = meta.name
    }
    
    var imagesFolder: URL{
        return LocalDataSource.shared.serieChaptersFolder.appendingPathComponent(oid!)
    }
    
    var imageURLs: [URL]{
        get{
            return try! jsonDecoder.decode([URL].self, from: encodedImageURLs!)
        }
        set{
            self.encodedImageURLs = try! jsonEncoder.encode(newValue)
        }
    }
    
    private func initializeImagesFolder(){
        try! FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true, attributes: nil)
    }
    
}
