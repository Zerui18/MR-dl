//
//  ZRTabBarController.swift
//  CustomUI
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

public class ZRNavigationController: UINavigationController {
    

    public var isStatusBarHidden = false{
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var statusBarStyleVar: UIStatusBarStyle = .default{
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var isNavigationBarTransparent: Bool = false{
        didSet{
            if isNavigationBarTransparent{
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
            }
            else{
                navigationBar.setBackgroundImage(nil, for: .default)
                navigationBar.shadowImage = nil
            }
        }
    }
    
    override public var prefersStatusBarHidden: Bool{
        return isStatusBarHidden
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .fade
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyleVar
    }
    
}

public extension UIViewController{
    
    public var shouldHideStatusBar: Bool?{
        get{
            return (navigationController as? ZRNavigationController)?.isStatusBarHidden
        }
        set{
            (navigationController as? ZRNavigationController)?.isStatusBarHidden = newValue!
        }
    }
    
    public var isNavBarTransparent: Bool?{
        get{
            return (navigationController as? ZRNavigationController)?.isNavigationBarTransparent
        }
        set{
            (navigationController as? ZRNavigationController)?.isNavigationBarTransparent = newValue!
        }
    }
   
    
    public var navBarItemsTintColor: UIColor?{
        get{
            return navigationController?.navigationBar.tintColor
        }
        set{
            navigationController?.navigationBar.tintColor = newValue
        }
    }
    
    public var statusBarStyle: UIStatusBarStyle?{
        get{
            return (navigationController as? ZRNavigationController)?.statusBarStyleVar
        }
        set{
            (navigationController as? ZRNavigationController)?.statusBarStyleVar = newValue!
        }
    }
    
}
