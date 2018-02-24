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


public class MRSerieMeta: NSObject, Codable {
    
    @objc public var statusDescription: String {
        return (completed ? "Completed, ":"Ongoing, ") + "\(chaptersCount) chapters"
    }
    
    @objc public var lastUpdatedDescription: String {
        return dateFormatter.string(from: updated)
    }
    
    @objc public var oid: String!
    @objc public var name: String!
    @objc public var author: String!
    @objc public var completed: Bool = false
    @objc public var updated: Date!
    @objc public var chaptersCount: Int = 0
    @objc public var serieDescription: String!
    @objc public var thumbnailURL: URL!
    @objc public var coverURL: URL!
    @objc public var artworkURLs: [URL]!
    @objc public var alias: [String]!
    
    public var chapters: [MRChapterMeta]!
    
    enum CodingKeys: String, CodingKey {
        case oid, name, author, completed, chapters, alias
        case updated = "last_update", chaptersCount = "total_chapters", thumbnailURL = "thumbnail", coverURL = "cover", artworkURLs = "artworks", serieDescription = "description"
    }
    
}
