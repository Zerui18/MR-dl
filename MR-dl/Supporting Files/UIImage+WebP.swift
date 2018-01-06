//
//  UIImage+WebPDecoder.swift
//  webp-swift
//
//  Created by Visoom on 06/10/2016.
//  Copyright © 2016 Visoom. All rights reserved.
//
//  Author: Visoom (m.falgari@gmail.com)


import UIKit
import MRClient

//Let's free some memory
private func freeWebPData(info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> Void {
    free(UnsafeMutableRawPointer(mutating: data))
}

extension UIImage{
    
    //MARK: Inits
    
    convenience init?(webPData data: Data) {
        guard let decodedImage = UIImage.webPDataToCGImage(data: data) else{
            return nil
        }
        self.init(cgImage: decodedImage)
    }
    
    convenience init?(mriData: Data){
        self.init(webPData: MRImageDataDecryptor.decrypt(data: mriData))
    }
    
    //MARK: WebP Decoder
    class func webPDataToCGImage(data: Data) -> CGImage? {
        
        var w: CInt = 0, h: CInt = 0
        
        //Get image dimensions
        guard getWebPInfo(data: data, width: &w, height: &h) else{
            return nil
        }
        
        //Data Provider
        var provider: CGDataProvider
        
        //RGBA by default
        let rawData = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            WebPDecodeRGBA(ptr, data.count, &w, &h)
        }
        
        provider = CGDataProvider(dataInfo: nil, data: rawData!, size: (Int(w)*Int(h)*4), releaseData: freeWebPData)!
        
        return UIImage.webPProviderToCGImage(provider: provider, width: w, height: h)
    }
    
    
    //Generate CGImage from decoded data
    class private func webPProviderToCGImage(provider: CGDataProvider, width w: CInt, height h: CInt) -> CGImage? {
        
        let bitmapWithAlpha = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        
        if let image = CGImage(width: Int(w), height: Int(h), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(w)*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapWithAlpha, provider: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent) {
            return image
        } else {
            return nil
        }
        
    }
    
    //MARK: UTILS
    //Get WebP image info (width and height)
    static private func getWebPInfo(data: Data, width: UnsafeMutablePointer<CInt>, height: UnsafeMutablePointer<CInt>)-> Bool{
        return [UInt8](data).withUnsafeBufferPointer({ptr in
            return WebPGetInfo(ptr.baseAddress!, data.count, width, height) == 1
        })
    }
    
//    private static let noAlphaCodes: [CGImageAlphaInfo] = [.none, .noneSkipLast, .noneSkipFirst]
//
//    public var hasAlpha: Bool{
//        let val = !UIImage.noAlphaCodes.contains(cgImage!.alphaInfo)
//        return val
//    }
//
//    typealias WebPPictureImporter = (UnsafeMutablePointer<WebPPicture>, UnsafeMutablePointer<UInt8>, Int32) -> Int32
//
//    public func webPEncoded(withQuality quality: Float=100) -> Data? {
//        guard let cgImage = cgImage else{
//            return nil
//        }
//        let stride = cgImage.bytesPerRow
//        let dataPtr = CFDataGetMutableBytePtr(cgImage.dataProvider!.data as! CFMutableData)!
//
//        let importer: WebPPictureImporter = { picturePtr, data, stride in
//            return self.hasAlpha ? WebPPictureImportRGBA(picturePtr, data, stride):WebPPictureImportRGB(picturePtr, data, stride)
//        }
//
//        var picture = WebPPicture()
//        if WebPPictureInit(&picture) == 0 {
//            fatalError("version error")
//        }
//
//        picture.use_argb = 1
//        picture.width = Int32(cgImage.width)
//        picture.height = Int32(cgImage.height)
//
//        if WebPPictureAlloc(&picture) == 0 {
//            fatalError("memory error")
//        }
//
//        let ok = importer(&picture, dataPtr, Int32(stride))
//        if ok == 0 {
//            WebPPictureFree(&picture)
//            fatalError("can't import picture")
//        }
//
//        var buffer = WebPMemoryWriter()
//        WebPMemoryWriterInit(&buffer)
//
//        let writeWebP: @convention(c) (UnsafePointer<UInt8>?, Int, UnsafePointer<WebPPicture>?) -> Int32 = { (data, size, picture) -> Int32 in
//            return WebPMemoryWrite(data, size, picture)
//        }
//        picture.writer = writeWebP
//        picture.custom_ptr = UnsafeMutableRawPointer(&buffer)
//
//        if WebPEncode(nil, &picture) == 0 {
//            WebPPictureFree(&picture)
//
//            print("encode error")
//            return nil
//        }
//        WebPPictureFree(&picture)
//
//        return Data(bytes: buffer.mem, count: buffer.size)
//
//    }
    
}
