//
//  ZRReactiveImageView.swift
//  CustomUI
//
//  Created by Chen Zerui on 25/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import ImageLoader

public protocol ZRImageLoading: class{
    func loadImage(with url: URL, into target: AnyObject, handler: @escaping Manager.Handler)
}

public class ZRReactiveImageView: ZRImageView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoadingIndicator()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLoadingIndicator()
    }
    
    private func setupLoadingIndicator(){
        loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .circles, color: #colorLiteral(red: 0, green: 0.4785608649, blue: 0.9994360805, alpha: 1))
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        loadingIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
        loadingIndicator.heightAnchor.constraint(equalTo: loadingIndicator.widthAnchor, multiplier: 1).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        layoutIfNeeded()
        addGestureRecognizer(tapToReload)
        tapToReload.isEnabled = false
    }
    
    var loadingIndicator: NVActivityIndicatorView!
    var imageURL: URL!
    var handler: ((UIImage)->Void)!
    weak var loader: ZRImageLoading!
    
    public func loadImage(withLoader loader: ZRImageLoading, fromURL url: URL, onSuccess handler:((UIImage)->Void)? = nil){
        self.loader = loader
        self.imageURL = url
        self.handler = handler
        loadingIndicator.startAnimating()
        loader.loadImage(with: url, into: self) { (result, _) in
            if let image = result.value{
                self.image = image
                self.tapToReload.isEnabled = false
                handler?(image)
            }
            else{
                self.tapToReload.isEnabled = true
            }
            self.loadingIndicator.stopAnimating()
        }
    }
    
    lazy var tapToReload = UITapGestureRecognizer(target: self, action: #selector(self.reloadImage))

    @objc private func reloadImage(){
        loadImage(withLoader: loader, fromURL: imageURL, onSuccess: handler)
    }
    
}
