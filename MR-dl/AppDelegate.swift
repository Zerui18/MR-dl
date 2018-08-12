//
//  AppDelegate.swift
//  MR-dl
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import UserNotifications
import CustomUI
import ImageLoader
import MRClient

let defaultAnimationDuration: TimeInterval = 0.2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate!
    
    var window: UIWindow?
    
    var topViewController: UIViewController? {
        if var topVC = window?.rootViewController {
            while let presented = topVC.presentedViewController, !(presented is UIAlertController) {
                topVC = presented
            }
            return topVC
        }
        return nil
    }
    
    var storyBoard: UIStoryboard!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        storyBoard = window!.rootViewController!.storyboard!
        ImagePipeline.sharedMRI = ImagePipeline {
            $0.imageDecoder = {_ in MRIDataDecoder(decryptFunction: MRImageDataDecryptor.decrypt, decodeFunction: UIImage.init(webPData:))}
        }
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        CoreDataHelper.shared.tryToSave()
    }
    
    
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // empty implementation for now
    }
    
    func reportError(error: Error, ofCategory category: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: category+" Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.topViewController?.present(alert, animated: true)
        }
    }
    
    func simpleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(identifier: "\(arc4random())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

