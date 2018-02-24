//
//  ZRReactiveImageView.swift
//  MR-dl
//
//  Created by Chen Zerui on 25/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import ImageLoader
import CustomUI

public class ReactiveThumbnailView: ZRImageView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoadingIndicator()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLoadingIndicator()
    }
    
    private func setupLoadingIndicator() {
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .circles, color: #colorLiteral(red: 0, green: 0.4785608649, blue: 0.9994360805, alpha: 1))
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        loadingIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
        loadingIndicator.heightAnchor.constraint(equalTo: loadingIndicator.widthAnchor, multiplier: 1).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        layoutIfNeeded()
    }
    
    var loadingIndicator: NVActivityIndicatorView!
    var imageURL: URL!
    var handler: ((UIImage)->Void)!
    
    public func loadImage(fromURL url: URL, onSuccess handler:((UIImage)->Void)? = nil) {
        self.imageURL = url
        self.handler = handler
        loadingIndicator.startAnimating()
        ThumbnailLoader.shared.loadImage(with: url, into: self) { (result, _) in
            DispatchQueue.main.async {
                if let image = result.value {
                    self.image = image
                    handler?(image)
                }
                self.loadingIndicator.stopAnimating()
            }
        }
    }

    @objc override public func imageViewTapped() {
        if image == nil {
            loadImage(fromURL: imageURL, onSuccess: handler)
        }
        else {
            super.imageViewTapped()
        }
    }
    
}
