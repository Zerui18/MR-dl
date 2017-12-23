//
//  MRCharacterMeta.swift
//  MRClient
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

public struct MRCharacterMeta: Codable{
    
    public let oid: String
    public let name: String
    public let bioMarkup: String
    public let thumbnailURL: URL
    public let artworkURLs: [URL]
    
    enum CodingKeys: String, CodingKey{
        case oid, name
        case bioMarkup = "bio", thumbnailURL = "thumbnail", artworkURLs = "artworks"
    }
}
