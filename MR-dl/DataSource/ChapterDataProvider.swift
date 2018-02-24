//
//  ChapterDataProviding.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

enum ChapterProperty: String {
    case oid, name, numberOfPages, imageURLs, lastUpdatedDescription
}


protocol ChapterDataProvider: class {
    func fetchImageURLs(completion:@escaping ([URL]?)-> Void)
    func fetchPage(atIndex index: Int, completion:@escaping (UIImage?)-> Void)
    subscript<ValueType>(property: ChapterProperty)-> ValueType? {get}
}
