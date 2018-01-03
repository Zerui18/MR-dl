//
//  ThumbnailLoader.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import CustomUI
import Cache
import ImageLoader


class ThumbnailLoader{
    
    static let shared = ThumbnailLoader()
    
    let cache: Storage
    let imageLoaderManager: Manager
    
    init(){
        cache = try! Storage(diskConfig: DiskConfig(name: "ThumbnailsLoaderCache", expiry: .never, maxSize: 1024*1024*100), memoryConfig: MemoryConfig(expiry: .never, countLimit: 200, totalCostLimit: 0))
        imageLoaderManager = Manager(loader: Loader(loader: DataLoader(), decoder: MRIDataDecoder(decryptFunction: {$0}, decodeFunction: {UIImage(data: $0)})), cache: cache)
    }
    
    func loadImage(with url: URL, into target: AnyObject, handler: @escaping Manager.Handler){
        imageLoaderManager.loadImage(with: url, into: target, handler: handler)
    }
    
}
