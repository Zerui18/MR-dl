//
//  UIView+Extension.swift
//  CustomUI
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

@IBDesignable
open class ZRImageView: UIImageView{
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        clipsToBounds = true
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))
    }
    
    @objc open func imageViewTapped(){
        UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5){
                self.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5){
                self.alpha = 1
            }
        }){_ in
            if let image = self.image{
                let ctr = ZRImageViewController(image: image)
                self.parentViewController?.present(ctr, animated: true)
            }
        }
    }
    
}
