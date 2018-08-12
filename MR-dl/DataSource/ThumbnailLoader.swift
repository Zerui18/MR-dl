//
//  ThumbnailLoader.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation
import ImageLoader

class ThumbnailLoader {
    
    static let shared = ThumbnailLoader()
    
    func loadImage(with url: URL, into target: ImageDisplayingView, completion: @escaping ImageTask.Completion) {
        var options = ImageLoadingOptions(transition: .fadeIn(duration: 0.3))
        options.pipeline = .shared
        ImageLoader.loadImage(with: url, options: options, into: target, progress: nil, completion: completion)
    }
    
}
