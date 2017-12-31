//
//  MRChapterMeta.swift
//  MRClient
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

public class MRChapterMeta: NSObject, Codable{
    
    public var lastUpdatedDescription: String{
        return dateFormatter.string(from: lastUpdated)
    }
    
    public let oid: String = .init()
    public let order: Int = 0
    public let name: String = .init()
    public let lastUpdated: Date = .init()
    
    public var imageURLs: [URL]?
    
    enum CodingKeys: String, CodingKey{
        case oid, order, name, imageURLs
        case lastUpdated = "updatedAt"
    }
    
    public func fetchImageURLs(completion:@escaping ([URL]?)-> Void){
        if imageURLs != nil{
            completion(imageURLs)
        }
        else{
            MRClient.getChapterImageURLs(forOid: oid) { (_, response) in
                self.imageURLs = response?.data
                completion(response?.data)
            }
        }
    }
    
}
