//
//  MRShortMeta.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

public struct MRShortMeta: Codable{
    
    public let name: String
    public let oid: String
    public let thumbnailURL: URL?
    
    enum CodingKeys: String, CodingKey{
        case name, oid
        case thumbnailURL = "thumbnail"
    }
    
}
