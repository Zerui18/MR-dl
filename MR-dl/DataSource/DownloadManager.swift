//
//  DownloadQueue.swift
//  MR-dl
//
//  Created by Chen Zerui on 27/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

class DownloadManager{
    
    static let shared = DownloadManager()
    
    var seriesDownloadQueue = [MRSerie]()
    
    init(){}
    
    func addToQueue(serie: MRSerie){
        seriesDownloadQueue.append(serie)
    }
    
}
