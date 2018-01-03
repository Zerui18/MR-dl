//
//  UIImage+HEIF.swift
//  MR-dl
//
//  Created by Chen Zerui on 3/1/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate let heifSourceOptions = [kCGImageSourceTypeIdentifierHint:AVFileType.heif.rawValue as CFString] as CFDictionary

extension UIImage{
    
    convenience init?(heicURL: URL) {
        if let source = CGImageSourceCreateWithURL(heicURL as CFURL, heifSourceOptions), let image = CGImageSourceCreateImageAtIndex(source, 0, nil){
            self.init(cgImage: image)
        }
        else{
            return nil
        }
    }

    @discardableResult
    func writeHeicRepresentation(toURL url: URL)-> Bool{
        if let destination = CGImageDestinationCreateWithURL(url as CFURL, AVFileType.heic as CFString, 1, nil){
            CGImageDestinationAddImage(destination, cgImage!, nil)
            CGImageDestinationFinalize(destination)
            return true
        }
        return false
    }
    
}
