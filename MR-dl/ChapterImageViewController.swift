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
    
    var chapterIndex: Int!
    var pageIndex: Int!
    var chapterURL: URL!{
        didSet{
            Manager.shared.loadImage(with: chapterURL) {[weak self] (result) in
                guard let weakSelf = self else{
                    return
                }
                weakSelf.image = result.value
                if weakSelf.imageView != nil{
                    DispatchQueue.main.async {
                        weakSelf.imageView.image = result.value
                        weakSelf.loadingIndicator.stopAnimating()
                        weakSelf.imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: weakSelf, action: #selector(weakSelf.didHoldImageView(_:))))
                    }
                }
            }
        }
    }
    
    var image: UIImage?
    
    let loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .circles, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChapterImagesPageViewController.shared?.currentPageIndex = pageIndex
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        scrollView.delegate = self
        if image != nil{
            imageView.image = image
            imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didHoldImageView(_:))))
        }
        else{
            setupLoadingIndicator()
        }
    }
    
    private func setupLoadingIndicator(){
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        loadingIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingIndicator.startAnimating()
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
