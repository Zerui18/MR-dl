//
//  ChapterImageTableViewCell.swift
//  MR-dl
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import MRClient
import CustomUI

class ChapterImageViewController: UIViewController {


    static func `init`(dataProvider: ChapterDataProvider, pageIndex: Int, chapterIndex: Int)-> ChapterImageViewController {
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImageCtr") as! ChapterImageViewController
        ctr.dataProvider = dataProvider
        ctr.pageIndex = pageIndex
        ctr.chapterIndex = chapterIndex
        return ctr
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageIndexLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var reloadButton: ZRBorderedButton!
    
    var dataProvider: ChapterDataProvider!
    var chapterIndex: Int!
    var pageIndex: Int!
    
    var image: UIImage?
    
    lazy var loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .circles, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    
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
    
    private func startLoadingImage() {
        loadingIndicator.startAnimating()
        dataProvider.fetchPage(atIndex: pageIndex) {[weak self] image in
            guard let strongSelf = self else {
                return
            }
            strongSelf.loadingIndicator.stopAnimating()
            if let image = image {
                strongSelf.image = image
                strongSelf.imageView.image = image
                strongSelf.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(strongSelf.didHoldImageView(_:))))
            }
            else {
                UIView.animate(withDuration: defaultAnimationDuration) {
                    strongSelf.errorLabel.alpha = 1
                    strongSelf.reloadButton.alpha = 1
                    strongSelf.reloadButton.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    let focusGesturePlaceholderView = UIView(frame: .zero)
    
    private func setupUI() {
        view.backgroundColor = .white
        pageIndexLabel.text = String(pageIndex+1)
        scrollView.delegate = self
        
        // only setup loadingIndicator & retry controls if loading image from external source
        if dataProvider is MRChapterMeta {
            setupLoadingIndicator()
            reloadButton.addTarget(self, action: #selector(triggerImageReload), for: .touchUpInside)
        }
        
        focusGesturePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(focusGesturePlaceholderView)
        focusGesturePlaceholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        focusGesturePlaceholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        focusGesturePlaceholderView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        focusGesturePlaceholderView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4).isActive = true
        let tapGesture = UITapGestureRecognizer(target: ChapterImagesPageViewController.shared!, action: #selector(ChapterImagesPageViewController.shared!.toggleFocus))
        tapGesture.cancelsTouchesInView = false
        focusGesturePlaceholderView.addGestureRecognizer(tapGesture)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        loadingIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        view.layoutIfNeeded()
    }
    
    @objc private func triggerImageReload() {
        errorLabel.alpha = 0
        reloadButton.isUserInteractionEnabled = false
        reloadButton.alpha = 0
        ChapterImagesPageViewController.shared?.startPreheatingIfNecessary()
        startLoadingImage()
    }

    @objc private func didHoldImageView(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let saveActionSheet = UIAlertController(title: "Save image?", message: "", preferredStyle: .actionSheet)
            saveActionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: {_ in
                UIImageWriteToSavedPhotosAlbum(self.image!, nil, nil, nil)
            }))
            saveActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(saveActionSheet, animated: true)
        }
    }
    
}

extension ChapterImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
