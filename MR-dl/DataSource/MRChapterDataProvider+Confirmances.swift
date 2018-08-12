//
//  MRChapterDataProvider+Confirmances.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import ImageLoader

extension MRChapterMeta: ChapterDataProvider {
    
    var numberOfPages: Int? {
        return imageURLs?.count
    }
    
    func fetchPage(atIndex index: Int, completion: @escaping (UIImage?) -> Void) {
        ImagePipeline.sharedMRI.loadImage(with: imageURLs![index]) { response, _ in
            completion(response?.image)
        }
    }
    
    subscript<ValueType>(property: ChapterProperty)-> ValueType? {
        return value(forKey: property.rawValue) as? ValueType
    }
    
}

extension MRChapter: ChapterDataProvider {
    
    var numberOfPages: Int? {
        return remoteImageURLs?.count
    }
    
    func fetchPage(atIndex index: Int, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage? = nil
            if let data = try? Data(contentsOf: self.addressForPage(atIndex: index)) {
                image = UIImage(data: data)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    subscript<ValueType>(property: ChapterProperty)-> ValueType? {
        return value(forKey: property.rawValue) as? ValueType
    }
    
}
