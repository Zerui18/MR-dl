//
//  ThumbnailLoader.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import Cache

typealias TLCompletion = (Error?, UIImage?)-> Void

class ThumbnailLoader{
    
    static let shared = ThumbnailLoader()
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    var activeRequests: [URL:TLCompletion] = [:]
    
    let thumbnailsStorage: Storage
    
    init(){
        let diskConfig = DiskConfig(name: "Thumbnails", expiry: .never, maxSize: 1024*1024*50)
        let memConfig = MemoryConfig(expiry: .never, countLimit: 30, totalCostLimit: 0)
        self.thumbnailsStorage = try! Storage(diskConfig: diskConfig, memoryConfig: memConfig)
    }
    
    func loadImage(_ request: URL, completion: @escaping TLCompletion){
        DispatchQueue.global().async {
            if let cachedWebPData = try? self.thumbnailsStorage.object(ofType: Data.self, forKey: request.absoluteString), let image = UIImage(data: cachedWebPData){
                completion(nil, image)
            }
            else if self.activeRequests[request] == nil{
                self.activeRequests[request] = completion
                self.urlSession.dataTask(with: request, completionHandler: { (data, _, error) in
                    let index = self.activeRequests.index(forKey: request)!
                    let callback = self.activeRequests.remove(at: index).value
                    if error != nil{
                        callback(error, nil)
                    }
                    else{
                        let image = UIImage(data: data!)!
                        try! self.thumbnailsStorage.setObject(UIImageJPEGRepresentation(image, 1.0)!, forKey: request.absoluteString)
                        callback(nil, image)
                    }
                }).resume()
            }
            else{
                self.activeRequests[request] = completion
            }
        }
    }
    
    func loadImage(_ request: URL, intoTarget target: NSObject, verificationCriteria criteria: @escaping ()-> Bool = {true}, success: ((UIImage)->Void)? = nil){
        loadImage(request) {[weak target] (error, image) in
            if let target = target, let image = image, criteria(){
                DispatchQueue.main.async {
                    target.setValue(image, forKey: "image")
                    success?(image)
                }
            }
        }
    }
    
}
