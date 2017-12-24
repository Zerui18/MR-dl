//
//  ChapterImageTableViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import MRImageLoader
import CustomUI

class ChapterImageViewController: UIViewController {


    static func `init`(imageURL mriImageURL: URL, pageIndex: Int, chapterIndex: Int)-> ChapterImageViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImageCtr") as! ChapterImageViewController
        ctr.chapterURL = mriImageURL
        ctr.pageIndex = pageIndex
        ctr.chapterIndex = chapterIndex
        return ctr
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var reloadButton: ZRBorderedButton!
    
    var chapterIndex: Int!
    var pageIndex: Int!
    var chapterURL: URL!
    
    //Reactive: image for the current-displaying page
    var image: UIImage?{
        didSet{
            if imageView != nil{
                loadingFinished()
            }
        }
    }
    
    let loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .circles, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLoadingImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChapterImagesPageViewController.shared?.currentPageIndex = pageIndex
        view.backgroundColor = ChapterImagesPageViewController.shared!.isFocused ? .black:.white
    }
    
    private func startLoadingImage(){
        loadingIndicator.startAnimating()
        Manager.shared.loadImage(with: chapterURL, into: imageView) {[weak self] (result, _) in
            guard let weakSelf = self else{
                return
            }
            if let error = result.error{
                print("MRImage Loading Error: ", error)
                UIView.animate(withDuration: defaultAnimationDuration){
                    weakSelf.errorLabel.alpha = 1
                    weakSelf.reloadButton.alpha = 1
                    weakSelf.reloadButton.isUserInteractionEnabled = true
                }
            }
            else{
                weakSelf.image = result.value
            }
        }
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        scrollView.delegate = self
        setupLoadingIndicator()
        reloadButton.addTarget(self, action: #selector(triggerImageReload), for: .touchUpInside)
    }
    
    private func setupLoadingIndicator(){
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        loadingIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc private func triggerImageReload(){
        errorLabel.alpha = 0
        reloadButton.isUserInteractionEnabled = false
        reloadButton.alpha = 0
        startLoadingImage()
    }
    
    // called after setting self.image to a non-nil value
    private func loadingFinished(){
        if imageView != nil{
            imageView.image = image
            loadingIndicator.stopAnimating()
            imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didHoldImageView(_:))))
        }
    }
    
    @objc private func didHoldImageView(_ sender: UILongPressGestureRecognizer){
        if sender.state == .began{
            let saveActionSheet = UIAlertController(title: "Save image?", message: "", preferredStyle: .actionSheet)
            saveActionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: {_ in
                UIImageWriteToSavedPhotosAlbum(self.image!, nil, nil, nil)
            }))
            saveActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(saveActionSheet, animated: true)
        }
    }
    
}

extension ChapterImageViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
