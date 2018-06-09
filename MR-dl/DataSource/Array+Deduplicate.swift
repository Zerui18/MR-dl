//
//  Array+Deduplicate.swift
//  MR-dl
//
//  Created by Chen Zerui on 21/4/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation

extension Array where Element == URL {
    
    func deduplicated()-> [URL] {
        var newArray = [URL]()
        for url in self where !newArray.contains(url) {
            newArray.append(url)
        }
        return newArray
    }
    
}
