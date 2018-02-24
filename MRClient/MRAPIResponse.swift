//
//  MRAPIResponse.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

public struct MRAPIResponse<T: Codable>: Codable {
    
    public let statusCode: Int
    public let data: T
    
    enum CodingKeys: String, CodingKey {
        case data
        case statusCode = "code"
    }
    
}

public typealias MRQuickSearchResponse = MRAPIResponse<[String:[String]]>
public typealias MRCompleteSearchResponse = MRAPIResponse<[String]>
public typealias MRShortMetasResponse = MRAPIResponse<[String:MRShortMeta]>
public typealias MRSerieMetaResponse = MRAPIResponse<MRSerieMeta>
public typealias MRSerieImageURLsResponse = MRAPIResponse<[URL]>

