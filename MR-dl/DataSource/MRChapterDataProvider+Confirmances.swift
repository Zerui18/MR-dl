//
//  MRChapterDataProvider+Confirmances.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import ImageLoader

extension MRChapterMeta: ChapterDataProvider{
    
    var numberOfPages: Int? {
        return imageURLs?.count
    }
    
    func fetchPage(atIndex index: Int, completion: @escaping (UIImage?) -> Void) {
        Manager.sharedMRImageManager.loadImage(with: imageURLs![index]) { result in
            completion(result.value)
        }
    }
    
    subscript<ValueType>(property: ChapterProperty)-> ValueType?{
        return value(forKey: property.rawValue) as? ValueType
    }
    
}

extension MRChapter: ChapterDataProvider{
    
    var numberOfPages: Int? {
        return remoteImageURLs?.count
    }
    
    func fetchPage(atIndex index: Int, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(heicURL: self.addressForPage(atIndex: index))
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    subscript<ValueType>(property: ChapterProperty)-> ValueType?{
        return value(forKey: property.rawValue) as? ValueType
    }
    
}
