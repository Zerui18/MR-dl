//
//  ZRImageViewController.swift
//  CustomUI
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

fileprivate let bundle = Bundle(for: ZRImageViewController.self)

public class ZRImageViewController: UIViewController {
    
    public init(image: UIImage) {
        super.init(nibName: "ZRImageViewController", bundle: bundle)
        self.image = image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var image: UIImage!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI(){
        imageView.image = image
        scrollView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
    }
    
    @objc private func tapped(){
        let shouldHide = closeButton.isUserInteractionEnabled
        
        UIView.animate(withDuration: 0.4, animations: {
            if shouldHide{
                self.scrollView.backgroundColor = .black
                self.closeButton.alpha = 0
                self.shareButton.alpha = 0
            }
            else{
                self.scrollView.backgroundColor = .white
                self.closeButton.alpha = 1
                self.shareButton.alpha = 1
            }
        }){_ in
            self.closeButton.isUserInteractionEnabled = !shouldHide
            self.shareButton.isUserInteractionEnabled = !shouldHide
        }
    }
    
    @objc private func close(){
        dismiss(animated: true)
    }
    
    @objc private func share(){
        let ctr = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(ctr, animated: true)
    }

}

extension ZRImageViewController: UIScrollViewDelegate{
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
