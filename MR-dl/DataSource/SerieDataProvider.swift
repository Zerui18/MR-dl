//
//  SerieDataProvider.swift
//  MR-dl
//
//  Created by Chen Zerui on 31/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

enum SerieProperty: String{
    case oid, name, thumbnailURL, author, lastUpdated, coverURL, serieDescription, artworkURLs, completed, chaptersCount, statusDescription, lastUpdatedDescription
}

protocol SerieDataProvider: class {
    func numberOfChapters(ofState state: DownloadState)-> Int
    func chapter(atIndex index: Int, forState state: DownloadState)-> ChapterDataProvider
    subscript<ValueType>(property: SerieProperty)-> ValueType? {get}
}
