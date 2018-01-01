//
//  MRCharacterMeta.swift
//  MRClient
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

@objcMembers
public class MRCharacterMeta: Codable{
    
    public var oid: String!
    public var name: String!
    public var bioMarkup: String!
    public var thumbnailURL: URL!
    public var artworkURLs: [URL]!
    
    enum CodingKeys: String, CodingKey{
        case oid, name
        case bioMarkup = "bio", thumbnailURL = "thumbnail", artworkURLs = "artworks"
    }
}
