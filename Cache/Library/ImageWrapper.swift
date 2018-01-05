import UIKit
import AVFoundation


//fileprivate extension UIImage{
//
//    convenience init?(heicData: Data) {
//        if let source = CGImageSourceCreateWithData(heicData as CFData, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil){
//            self.init(cgImage: image)
//        }
//        else{
//            return nil
//        }
//    }
//
//    func heicRepresentation()-> Data?{
//        let imageData = NSMutableData()
//        if let destination = CGImageDestinationCreateWithData(imageData as CFMutableData, AVFileType.heic.rawValue as CFString, 1, nil){
//            CGImageDestinationAddImage(destination, cgImage!, nil)
//            CGImageDestinationFinalize(destination)
//            return imageData as Data
//        }
//        return nil
//    }
//
//}

public struct ImageWrapper: Codable {
  public let image: UIImage

  public enum CodingKeys: String, CodingKey {
    case image
  }

  public init(image: UIImage) {
    self.image = image
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let data = try container.decode(Data.self, forKey: CodingKeys.image)
    guard let image = UIImage(data: data) else {
      throw StorageError.decodingFailed
    }

    self.image = image
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    guard let data = UIImageJPEGRepresentation(image, 1) else {
        throw StorageError.encodingFailed
    }

    try container.encode(data, forKey: CodingKeys.image)
  }
}
