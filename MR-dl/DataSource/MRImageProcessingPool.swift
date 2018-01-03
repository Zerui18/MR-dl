//
//  MRImageProcessingPool.swift
//  MR-dl
//
//  Created by Chen Zerui on 3/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import Foundation

class MRImageProcessingPool{
    
    static let shared = MRImageProcessingPool()
    
    private let processingQueues: [DispatchQueue]
    private var queuingTasks = [(source: URL, destination: URL)]()
    
    init(numberOfQueues: Int = ProcessInfo().activeProcessorCount){
        print("initialized threadpool with: \(numberOfQueues) queues!")
        processingQueues = [Int](0..<numberOfQueues).map{
            DispatchQueue(label: "com.Zerui.ThreadPool.Queue-\($0)", qos: .userInitiated)
        }
        
    }
    
    func recode(data: Data, to destination: URL){
        
    }
    
}
