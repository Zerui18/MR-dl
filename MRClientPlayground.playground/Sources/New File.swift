import UIKit

public func test(){
    let path = "/Users/chenzerui/Desktop/MR-dl/MRClientPlayground.playground/Resources/up_anime_noise1_scale2x_model.mlmodel"
    let time = Date()
    for _ in 0...9999{
        FileManager.default.fileExists(atPath: path)
    }
    let interval = -time.timeIntervalSinceNow
    print("total: ", interval)
    print("average: ", interval/10000)
}
