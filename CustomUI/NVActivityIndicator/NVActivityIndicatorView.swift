//
//  NVActivityIndicatorView.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

public final class NVActivityIndicatorView: UIView {
    
    public enum AnimationType {
        case circles, balls
    }
    
    /// Default color of activity indicator. Default value is UIColor.white.
    public static var DEFAULT_COLOR = UIColor.white
    
    /// Default color of text. Default value is UIColor.white.
    public static var DEFAULT_TEXT_COLOR = UIColor.white
    
    /// Default padding. Default value is 0.
    public static var DEFAULT_PADDING: CGFloat = 0
    
    /// Default size of activity indicator view in UI blocker. Default value is 60x60.
    public static var DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
    
    /// Default display time threshold to actually display UI blocker. Default value is 0 ms.
    ///
    /// - note:
    /// Default time that has to be elapsed (between calls of `startAnimating()` and `stopAnimating()`) in order to actually display UI blocker. It should be set thinking about what the minimum duration of an activity is to be worth showing it to the user. If the activity ends before this time threshold, then it will not be displayed at all.
    public static var DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 0
    
    /// Default minimum display time of UI blocker. Default value is 0 ms.
    ///
    /// - note:
    /// Default minimum display time of UI blocker. Its main purpose is to avoid flashes showing and hiding it so fast. For instance, setting it to 200ms will force UI blocker to be shown for at least this time (regardless of calling `stopAnimating()` ealier).
    public static var DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME = 0
    
    /// Default message displayed in UI blocker. Default value is nil.
    public static var DEFAULT_BLOCKER_MESSAGE: String?
    
    /// Default message spacing to activity indicator view in UI blocker. Default value is 8.
    public static var DEFAULT_BLOCKER_MESSAGE_SPACING = CGFloat(8.0)
    
    /// Default font of message displayed in UI blocker. Default value is bold system font, size 20.
    public static var DEFAULT_BLOCKER_MESSAGE_FONT = UIFont.boldSystemFont(ofSize: 20)
    
    /// Default background color of UI blocker. Default value is UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    public static var DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    /// Color of activity indicator view.
    @IBInspectable public var color: UIColor = NVActivityIndicatorView.DEFAULT_COLOR
    
    /// Padding of activity indicator view.
    @IBInspectable public var padding: CGFloat = NVActivityIndicatorView.DEFAULT_PADDING
    
    /// Current status of animation, read-only.
    @available(*, deprecated: 3.1)
    public var animating: Bool { return isAnimating }
    
    /// Current status of animation, read-only.
    private(set) public var isAnimating: Bool = false
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("NVActivityIndicatorView cannot be initialized from decoder!")
    }
    
    /**
     Create a activity indicator view.
     Appropriate NVActivityIndicatorView.DEFAULT_* values are used for omitted params.
     - parameter frame:   view's frame.
     - parameter type:    animation type.
     - parameter color:   color of activity indicator view.
     - parameter padding: padding of activity indicator view.
     - returns: The activity indicator view.
     */
    public init(frame: CGRect, type: AnimationType, color: UIColor? = nil, padding: CGFloat? = nil) {
        self.color = color ?? NVActivityIndicatorView.DEFAULT_COLOR
        self.padding = padding ?? NVActivityIndicatorView.DEFAULT_PADDING
        self.type = type
        super.init(frame: frame)
        isHidden = true
    }
    
    var type: AnimationType = .balls
    
    // Fix issue #62
    // Intrinsic content size is used in autolayout
    // that causes mislayout when using with MBProgressHUD.
    /**
     Returns the natural size for the receiving view, considering only properties of the view itself.
     A size indicating the natural size for the receiving view based on its intrinsic properties.
     - returns: A size indicating the natural size for the receiving view based on its intrinsic properties.
     */
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    public override var bounds: CGRect {
        didSet {
            // setup the animation again for the new bounds
            if oldValue != bounds && isAnimating {
                setUpAnimation()
            }
        }
    }
    
    /**
     Start animating.
     */
    public final func startAnimating() {
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setUpAnimation()
    }
    
    /**
     Stop animating.
     */
    public final func stopAnimating() {
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }
    
    // MARK: Privates
    private final func setUpAnimation() {
        let animation: NVActivityIndicatorAnimationDelegate = type == .balls ? NVActivityIndicatorAnimationBallTrianglePath():NVActivityIndicatorAnimationBallClipRotateMultiple()
        var animationRect = frame.inset(by: UIEdgeInsets.init(top: padding, left: padding, bottom: padding, right: padding))
        let minEdge = min(animationRect.width, animationRect.height)
        
        layer.sublayers = nil
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        animation.setUpAnimation(in: layer, size: animationRect.size, color: color)
    }
}
