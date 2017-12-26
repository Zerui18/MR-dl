//
//  ChapterImagesTableViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 22/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import MRClient
import ImageLoader

class ChapterImagesPageViewController: UIPageViewController {
    
    var imagePreheater: Preheater?
    
    static func `init`(forSerie serieMeta: MRSerieMeta, atChapter chapterIndex: Int, localSource: Manager?)-> ChapterImagesPageViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImagesCtr") as! ChapterImagesPageViewController
        ctr.serieMeta = serieMeta
        ctr.chapterIndex = chapterIndex
        if localSource != nil{
            
        }
        else{
            ctr.imagePreheater = Preheater(manager: .shared, maxConcurrentRequestCount: 4)
        }
        return ctr
    }
    
    static weak var shared: ChapterImagesPageViewController?
    
    @IBOutlet weak var chapterIndexButon: UIBarButtonItem!
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //Reactive: whether to focus on the image view by hiding other UI components
    var isFocused = false{
        didSet{
            UIView.animate(withDuration: defaultAnimationDuration) {
                self.shouldHideStatusBar = self.isFocused
                self.viewControllers?.first?.view.backgroundColor = self.isFocused ? .black:.white
            }
            navigationController?.setNavigationBarHidden(isFocused, animated: true)
        }
    }
    
    // current-displaying serie-meta
    var serieMeta: MRSerieMeta!
    
    var shouldLoadReversed = false
    
    //Reactive: chapterImageURLs for current-diplaying chapter
    var chapterImageURLs: [URL]?{
        didSet{
            if let preheater = imagePreheater{
                let requests = chapterImageURLs!.map{Request(url: $0)}
                imagePreheater?.stopPreheating()
                imagePreheater?.startPreheating(with: shouldLoadReversed ? requests.reversed():requests)
            }
            goto(pageIndex: shouldLoadReversed ? chapterImageURLs!.count-1:0)
            chapterIndexButon.isEnabled = true
        }
    }
    
    //Reactive: current-displaying chapter index
    var chapterIndex: Int!{
        didSet{
            navigationItem.title = chapter.name
        }
    }
    
    // current-displaying chapter
    var chapter: MRSerieMeta.ChapterMeta{
        return serieMeta.chapters[chapterIndex]
    }
    
    //Reactive: current-displaying page index, 0-indexed
    var currentPageIndex = 0{
        didSet{
            chapterIndexButon.title = "\(currentPageIndex+1)/\(chapterImageURLs!.count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChapterImagesPageViewController.shared = self
        setupUI()
        fetchImageURLs(forChapterIndex: chapterIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        imagePreheater?.stopPreheating()
    }
    
    let focusGesturePlaceholderView = UIView(frame: .zero)
    lazy var contentView: UIView = {
       return value(forKey: "_contentView") as! UIView
    }()
    
    private func setupUI(){

        navigationItem.title = chapter.name
        dataSource = self
        delegate = self
        
        chapterIndexButon.target = self
        chapterIndexButon.action = #selector(showPagesSelector)
        
        focusGesturePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(focusGesturePlaceholderView)
        focusGesturePlaceholderView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        focusGesturePlaceholderView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        focusGesturePlaceholderView.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        focusGesturePlaceholderView.widthAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4).isActive = true
        focusGesturePlaceholderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFocus)))
    }
    
    @objc private func toggleFocus(){
        isFocused = !isFocused
    }
    
    // fetch image urls for current chapter
    private func fetchImageURLs(forChapterIndex index: Int){
        chapterIndexButon.isEnabled = false
        let blockingAlert = UIAlertController(title: "Loading Chapter \(chapterIndex+1)", message: "", preferredStyle: .alert)
        present(blockingAlert, animated: false)
        MRClient.getChapterImageURLs(forOid: chapter.oid) {(error, response) in
            DispatchQueue.main.async {
                self.presentedViewController?.dismiss(animated: true)
                if let imageURLs = response?.data{
                    self.chapterIndex = index
                    self.chapterImageURLs = imageURLs
                }
                else{
                    blockingAlert.title = "Network Error"
                    blockingAlert.message = "Failed to load image-urls for chapter, please check your network connectivity."
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false){_ in
                        blockingAlert.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    // present a picker view controller to jump to page
    @objc private func showPagesSelector(){
        let pickerController = ZRPickerViewController(options: [Int](1...chapterImageURLs!.count).map{"page \($0)"}, selected: currentPageIndex)
        pickerController.onSelection = {selectedIndex in
            if selectedIndex != self.currentPageIndex{
                self.goto(pageIndex: selectedIndex)
            }
        }
        AppDelegate.shared.window?.rootViewController?.present(pickerController, animated: true)
    }
    
    // animate flip to specified page index
    private func goto(pageIndex: Int){
        guard let urls = chapterImageURLs else{
            return
        }
        var reversedDirection: UIPageViewControllerNavigationDirection = pageIndex >= currentPageIndex ? .reverse:.forward
        // check for special cases
        // next chapter, flip forward
        if pageIndex == 0{
            reversedDirection = .reverse
        }
            // last chapter, flip bakward
        else if pageIndex == urls.count-1{
            reversedDirection = .forward
        }
        setViewControllers([ChapterImageViewController(imageURL: urls[pageIndex], pageIndex: pageIndex, chapterIndex: chapterIndex)], direction: reversedDirection, animated: true){_ in
            self.contentView.bringSubview(toFront: self.focusGesturePlaceholderView)
        }
    }

}

extension ChapterImagesPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    func alert(title: String, message: String){
        let alertCtr = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtr.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertCtr, animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // does not do anything if this chapter has not loaded
        if let urls = chapterImageURLs{
            let sourceIndex = (viewController as! ChapterImageViewController).pageIndex!
            if sourceIndex+1 >= chapterImageURLs!.count{
                // load next chapter if exists
                if chapterIndex+1 < serieMeta.chaptersCount{
                    shouldLoadReversed = false
                    fetchImageURLs(forChapterIndex: chapterIndex+1)
                }
                else{
                    alert(title: "Last Chapter", message: "This is already the last chapter!")
                    HapticsController.notificationFeedback(ofType: .warning)
                }
            }
            else{
                // load next page
                return ChapterImageViewController(imageURL: urls[sourceIndex+1], pageIndex: sourceIndex+1, chapterIndex: chapterIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // does not do anything if this chapter has not loaded
        if let urls = chapterImageURLs{
            let sourceIndex = (viewController as! ChapterImageViewController).pageIndex!
            if sourceIndex-1 < 0{
                // load prev chapter if exists
                if chapterIndex-1 >= 0{
                    shouldLoadReversed = true
                    fetchImageURLs(forChapterIndex: chapterIndex-1)
                }
                else{
                    alert(title: "First Chapter", message: "This is already the first chapter!")
                    HapticsController.notificationFeedback(ofType: .warning)
                }
            }
            else{
                // load prev page
                return ChapterImageViewController(imageURL: urls[sourceIndex-1], pageIndex: sourceIndex-1, chapterIndex: chapterIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if !isFocused{
            isFocused = true
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        contentView.bringSubview(toFront: focusGesturePlaceholderView)
    }
    
}
