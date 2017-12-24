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
    
    convenience init(fromMeta meta: MRSerieMeta.ChapterMeta, serie: MRSerie, context: NSManagedObjectContext) {
        self.init(context: context)
        self.dateUpdated = meta.updated
        self.oid = meta.oid
        self.name = meta.name
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
            self.encodedImageURLs = try! jsonEncoder.encode(newValue)
        }
    }
    var _imageURLs: [URL]?
    
}

extension MRChapter{
    
    enum DownloadState: Int16{
        case none=0, downloading, downloaded
    }
    
    func fetchImageURLs(completion:@escaping ([URL]?)->Void){
        MRClient.getChapterImageURLs(forOid: oid!) { (error, response) in
            completion(response?.data)
        }
    }
    
    var downloadState: DownloadState{
        get{
            return DownloadState(rawValue: downloadStateRaw)!
        }
        set{
            downloadStateRaw = newValue.rawValue
        }
    }
    
}
