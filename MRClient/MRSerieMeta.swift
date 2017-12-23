//
//  MRSerieMeta.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd MMM yyyy"
    return f
}()

public struct MRSerieMeta: Codable{
    
    public struct ChapterMeta: Codable{
        
        public var lastUpdatedDescription: String{
            return dateFormatter.string(from: updated)
        }
        
        public let oid: String
        public let order: Int
        public let name: String
        public let updated: Date
        
        enum CodingKeys: String, CodingKey{
            case oid, order, name
            case updated = "updatedAt"
        }
        
    }
    
    public var statusDescription: String{
        return (completed ? "Completed, ":"Ongoing, ") + "\(chaptersCount) chapters"
    }
    
    public var lastUpdatedDescription: String{
        return dateFormatter.string(from: updated)
    }
    
    public let oid: String
    public let name: String
    public let author: String
    public let completed: Bool
    public let updated: Date
    public let chaptersCount: Int
    public let description: String
    public let thumbnailURL: URL
    public let coverURL: URL
    public let artworkURLs: [URL]
    public let alias: [String]
    
    public let chapters: [ChapterMeta]
    
    enum CodingKeys: String, CodingKey{
        case oid, name, author, completed, description, chapters
        case updated = "last_update", chaptersCount = "total_chapters", thumbnailURL = "thumbnail", coverURL = "cover", artworkURLs = "artworks", alias
    }
    
}
