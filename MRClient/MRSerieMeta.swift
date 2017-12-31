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

public class MRSerieMeta: NSObject, Codable{
    
    public var statusDescription: String{
        return (completed ? "Completed, ":"Ongoing, ") + "\(chaptersCount) chapters"
    }
    
    public var lastUpdatedDescription: String{
        return dateFormatter.string(from: updated)
    }
    
    public let oid: String = .init()
    public let name: String = .init()
    public let author: String = .init()
    public let completed: Bool = false
    public let updated: Date = .init()
    public let chaptersCount: Int = 0
    public let serieDescription: String = .init()
    public let thumbnailURL: URL = .init(fileURLWithPath: "/")
    public let coverURL: URL = .init(fileURLWithPath: "/")
    public let artworkURLs: [URL] = .init()
    public let alias: [String] = .init()
    
    public let chapters: [MRChapterMeta] = .init()
    
    enum CodingKeys: String, CodingKey{
        case oid, name, author, completed, chapters, alias
        case updated = "last_update", chaptersCount = "total_chapters", thumbnailURL = "thumbnail", coverURL = "cover", artworkURLs = "artworks", serieDescription = "description"
    }
    
}
