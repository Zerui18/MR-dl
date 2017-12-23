//
//  AppDelegate.swift
//  MR-dl
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import MRImageLoader
import MRClient

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
    
    let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        Loader.shared = Loader(loader: DataLoader(), decoder: MRIDataDecoder(decryptFunction: {
            MRImageDataDecryptor.decrypt(data: $0)
        }, decodeFunction: {
            UIImage(webPData: $0)
        }))
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func reportError(error: Error, ofCategory category: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: category+" Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.topViewController?.present(alert, animated: true)
        }
    }
}

