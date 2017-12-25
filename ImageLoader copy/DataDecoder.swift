// The MIT License (MIT)
//
// Copyright (c) 2017 Alexander Grebenyuk (github.com/kean).

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

#if os(watchOS)
    import WatchKit
#endif

/// Decodes image data.
public protocol DataDecoding {
    /// Decodes image data.
    func decode(data: Data, response: URLResponse) -> Image?
}

/// Decodes image data.
public struct MRIDataDecoder: DataDecoding {
    private let decryptFunction: DataDecryptFunction
    private let decodeFunction: ImageDecodeFunction
    
    public init(decryptFunction:@escaping DataDecryptFunction, decodeFunction:@escaping ImageDecodeFunction){
        self.decryptFunction = decryptFunction
        self.decodeFunction = decodeFunction
    }
    
    public func decode(data: Data, response: URLResponse) -> Image? {
        return decodeFunction(decryptFunction(data))
    }
}

public typealias ImageDecodeFunction = (_ imageData: Data)-> UIImage?
public typealias DataDecryptFunction = (_ encryptedData: Data)-> Data

