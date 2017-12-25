//
//  AppDelegate.swift
//  MR-dl
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import ImageLoader
import MRClient

let defaultAnimationDuration: TimeInterval = 0.2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate!
    
    var window: UIWindow?
    
    var topViewController: UIViewController?{
        if var topVC = window?.rootViewController{
            while let presented = topVC.presentedViewController, !(presented is UIAlertController){
                topVC = presented
            }
            return topVC
        }
        return nil
    }
    
    var storyBoard: UIStoryboard!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        storyBoard = window!.rootViewController!.storyboard!
        Loader.shared = Loader(loader: DataLoader(), decoder: MRIDataDecoder(decryptFunction: {
            MRImageDataDecryptor.decrypt(data: $0)
        }, decodeFunction: {
            UIImage(webPData: $0)
        }))
        return true
    }
    
    func reportError(error: Error, ofCategory category: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: category+" Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.topViewController?.present(alert, animated: true)
        }
    }
}

