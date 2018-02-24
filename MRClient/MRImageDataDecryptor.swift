//
//  MRImageDataDecryptor.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

public class MRImageDataDecryptor {
    
    public static func decrypt(data: Data)-> Data {
        var array = [UInt8](data)
        
        var newArray = [UInt8](repeating: 0, count: array.count + 15)
        
        if array[0] == 69 {
            
            let n = array.count + 7
            newArray[0] = 82
            newArray[1] = 73
            newArray[2] = 70
            newArray[3] = 70
            newArray[7] = UInt8(n >> 24 & 255)
            newArray[6] = UInt8(n >> 16 & 255)
            newArray[5] = UInt8(n >> 8 & 255)
            newArray[4] = UInt8(n & 255)
            newArray[8] = 87
            newArray[9] = 69
            newArray[10] = 66
            newArray[11] = 80
            newArray[12] = 86
            newArray[13] = 80
            newArray[14] = 56
            for i in 0..<array.count {
                newArray[i + 15] = 101 ^ array[i]
            }
            
        }
        return NSData(bytes: &newArray, length: newArray.count) as Data
    }
    
}
