//
//  MRClient.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Cache
import Foundation

public class MRClient {
    
    // MARK: Constant declarations
    public enum SearchCategory: String {
        case series, character, author
    }
    
    static let quickSearchURL = URL(string: "https://api.mangarockhd.com/query/web401/mrs_quick_search?country=Singapore")!
    static let searchURL = URL(string: "https://api.mangarockhd.com/query/web401/mrs_search?country=Singapore")!
    static let getMetasURL = URL(string: "https://api.mangarockhd.com/meta")!

    static let metaStorage = try! Storage(diskConfig: DiskConfig(name: "Meta", expiry: .date(Date(timeIntervalSinceNow: 7*24*3600)), maxSize: 1024*1024*100), memoryConfig: MemoryConfig(expiry: .never, countLimit: 200, totalCostLimit: 0))
    
    // MARK: Request-construction Methods
    /**
     Construct a "POST" URLRequest to perform a quick search given a query String. Request data should be decodable to a MRQuickSearchResponse object.
     - parameters:
        - query: search query string
     - returns: the constructed URLRequest object
     */
    static func getQuickSearchRequest(forQuery query: String)-> URLRequest {
        var request = URLRequest(url: quickSearchURL)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: .utf8)
        return request
    }
    
    /**
     Construct a "POST" URLRequest to perform a normal search given a query String and a category to search from. Response data should be decodable to MRSearchResponse object.
     - parameters:
        - query: search query string
        - category: the category in which to lookup the query
     - returns: the constructed URLRequest object
     */
    static func getCompleteSearchRequest(forQuery query: String, category: SearchCategory)-> URLRequest {
        var request = URLRequest(url: searchURL)
        request.httpMethod = "POST"
        let queryDict = ["type" : category.rawValue, "keywords" : query]
        request.httpBody = try! JSONSerialization.data(withJSONObject: queryDict, options: [])
        return request
    }
    
    /**
     Construct a "POST" URLRequest to fetch basic meta-data for a list of oids. Response data should be decodable to a MRShortMetasResponse object.
     - parameters:
        - oids: array of oids to fetch meta for, which can be from a mix of different categories
     - returns: the constructed URLRequest object
     */
    static func getMetasRequest(forOids oids: [String])-> URLRequest {
        var request = URLRequest(url: getMetasURL)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: oids, options: [])
        return request
    }
    
    /**
     Costruct a "GET" URLRequest to fetch full meta-data for an "mrs-serie" oid. Reqponse data should be decodable to a MRSerieMetaResponse object.
     - parameters:
        - oid: oid of the serie to fetch meta-data for
     - returns: the constructed URLRequest object
     */
    static func getSerieMetaRequest(forOid oid: String)-> URLRequest {
        let url = URL(string: "https://api.mangarockhd.com/query/web401/info?oid=\(oid)&last=0&country=Singapore")!
        return URLRequest(url: url)
    }
    
    /**
     Construct a "GET" URLRequest to fetch an array of MRImage-URLs. Response data should be decodable to a MRSerieImagesResponse object.
     - parameters:
        - oid: oid of the serie to fetch image-urls for
     - returns: the constructed URLRequest object
     */
    static func getChapterImageUrlsRequest(forOid oid: String)-> URLRequest {
        let url = URL(string: "https://api.mangarockhd.com/query/web401/pages?oid=\(oid)&country=Singapore")!
        return URLRequest(url: url)
    }
    
//    /**
//     Construct a "GET" URLRequest to fetch meta-data for a character given the oid.
//     - parameters:
//        - oid: oid of the character to fetch meta-data for
//     - returns: the contructed URLRequest object
//     */
//    public static func getCharacterMetaRequest(forOid oid: String)-> URLRequest {
//        let url = URL(string: "https://api.mangarockhd.com/query/web401/character?oid=\(oid)")!
//        return URLRequest(url: url)
//    }

    
    // MARK: Top-level interaction methods
    
    /**
     Fetch results of quick search with the given query.
     - parameters:
        - query: search query string
        - completion: completion handler to be called on task complete
        - error: Optional error which might be encountered during fetch
        - response: Optional response which might be nil due to error during fetch
     */
    public static func quickSearch(forQuery query: String, completion: @escaping (_ error: Error?, _ response: MRQuickSearchResponse?)-> Void) {
        getQuickSearchRequest(forQuery: query).fetch(completion: completion)
    }
    
    /**
     Fetch results of search with the given query constrained to the goven category.
     - parameters:
        - query: search query string
        - category: the category in which to lookup the query
        - completion: completion handler to be called on task complete
        - error: Optional error which might be encountered during fetch
        - response: Optional response which might be nil due to error during fetch
     */
    public static func completeSearch(forQuery query: String, category: SearchCategory, completion: @escaping (_ error: Error?, _ response: MRCompleteSearchResponse?)-> Void) {
        getCompleteSearchRequest(forQuery: query, category: category).fetch(completion: completion)
    }
    
    /**
     Fetch short-metas for the given oids.
     - parameters:
        - oids: array of oids to fetch meta for, which can be from a mix of different categories
        - completion: completion handler to be called on task complete
        - error: Optional error which might be encountered during fetch
        - response: Optional response which might be nil due to error during fetch
     */
    public static func getMetas(forOids oids: [String], completion: @escaping (_ error: Error?, _ response: MRShortMetasResponse?)-> Void) {
        var oids = oids
        var metas = [String:MRShortMeta]()
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, oid) in oids.enumerated().reversed() {
                if let meta = try? metaStorage.object(ofType: MRShortMeta.self, forKey: "meta-"+oid) {
                    oids.remove(at: index)
                    metas[oid] = meta
                }
            }
            guard !oids.isEmpty else {
                completion(nil, MRShortMetasResponse(statusCode: 0, data: metas))
                return
            }
            getMetasRequest(forOids: oids).fetch(completion: { (error, response: MRShortMetasResponse?) in
                if let newMetas = response?.data {
                    for (oid, meta) in newMetas {
                        try! metaStorage.setObject(meta, forKey: "meta-"+oid)
                    }
                    metas.merge(newMetas, uniquingKeysWith: {meta1, meta2 in
                        return meta1
                    })
                }
                else if metas.isEmpty {
                    completion(error, nil)
                    return
                }
                completion(error, MRShortMetasResponse(statusCode: 0, data: metas))
            })
        }
    }
    
    /**
     Fetch the serie's meta for the given "mrs-serie" oid.
     - parameters:
        - oid: oid of the serie to fetch meta-data for
        - completion: completion handler to be called on task complete
        - error: Optional error which might be encountered during fetch
        - response: Optional response which might be nil due to error during fetch
     */
    public static func getSerieMeta(forOid oid: String, completion: @escaping (_ error: Error?, _ response: MRSerieMetaResponse?)-> Void) {
        getSerieMetaRequest(forOid: oid).fetch(completion: completion)
    }
    
    /**
     Fetch image-urls for the give the "mrs-chapter" oid.
     - parameters:
        - oid: oid of the chapter to fetch image-urls for
        - completion: completion handler to be called on task complete
        - error: Optional error which might be encountered during fetch
        - response: Optional response which might be nil due to error during fetch
     */
    public static func getChapterImageURLs(forOid oid: String, completion: @escaping (_ error: Error?, _ response: MRSerieImageURLsResponse?)-> Void) {
        getChapterImageUrlsRequest(forOid: oid).fetch(completion: completion)
    }
    
//    /**
//     Fetch the character's meta for the given the "mrs-character" oid.
//     - parameters:
//        - oid: oid of the character to fetch meta-data for
//        - completion: completion handler to be called on task complete
//        - error: Optional error which might be encountered during fetch
//        - response: Optional response which might be nil due to error during fetch
//     */
//    public static func getCharacterMeta(forOid oid: String, completion: @escaping (_ error: Error?, _ response: MRCharacterMetaResponse?)-> Void) {
//        getCharacterMetaRequest(forOid: oid).fetch(completion: completion)
//    }
    
}


