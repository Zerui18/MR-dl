//
//  MRClientTests.swift
//  MRClientTests
//
//  Created by Chen Zerui on 9/3/18.
//  Copyright © 2018 Chen Zerui. All rights reserved.
//

@testable import MR_dl
import XCTest
import MRClient

class MRClientTests: XCTestCase {
    
    func testDecrypt(){
        let data = try! Data(contentsOf: URL(string: "https://f01.mrcdn.info/file/mrfiles/i/3/2/i/OG.kexVVJuY.mri")!)
        
        measure {
            _ = MRImageDataDecryptor.decrypt(data: data)
        }

        let decrypted = MRImageDataDecryptor.decrypt(data: data)
        
        measure {
            _ = UIImage(webPData: decrypted)!
        }
    }
    
}
