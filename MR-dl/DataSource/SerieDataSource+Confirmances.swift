//
//  SerieDataSource+Confirmances.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient

extension MRSerieMeta: SerieDataProvider{

    func numberOfChapters(ofState state: DownloadState) -> Int {
        if state == .downloaded{
            return 0
        }
        return chaptersCount
    }
    
    func chapter(atIndex index: Int, forState state: DownloadState) -> ChapterDataProvider {
        return chapters[index]
    }
    
    subscript<ValueType>(property: SerieProperty)-> ValueType?{
        return value(forKey: property.rawValue) as? ValueType
    }
    
}

extension MRSerie: SerieDataProvider{
    
    func numberOfChapters(ofState state: DownloadState) -> Int {
        if state == .downloaded{
            return downloader.downloadedChapters.count
        }
        else{
            return downloader.notDownloadedChapters.count
        }
    }
    
    func chapter(atIndex index: Int, forState state: DownloadState) -> ChapterDataProvider {
        if state == .downloaded{
            return downloader.downloadedChapters[index]
        }
        else{
            return downloader.notDownloadedChapters[index]
        }
    }
    
    var chaptersCount: Int{
        return Int(chaptersCountRaw)
    }
    
    subscript<ValueType>(property: SerieProperty)-> ValueType?{
        return value(forKey: property.rawValue) as? ValueType
    }
    
}
