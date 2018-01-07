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
    var imageLoadingManager: Manager?
    
    static func `init`(dataProvider: SerieDataProvider, atChapter chapterIndex: Int)-> ChapterImagesPageViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImagesCtr") as! ChapterImagesPageViewController
        ctr.serieDataProvider = dataProvider
        ctr.chapterIndex = chapterIndex
        
        if dataProvider is MRSerieMeta{
            // loading from remote source, enable preheating with MRImage support
            ctr.imageLoadingManager = .sharedMRImageManager
            ctr.imagePreheater = Preheater(manager: .sharedMRImageManager, maxConcurrentRequestCount: 4)
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
    var serieDataProvider: SerieDataProvider!
    
    var shouldLoadReversed = false
    
    //Reactive: chapterImageURLs for current-diplaying chapter
    var chapterImageURLs: [URL]?{
        didSet{
            startPreheatingIfNecessary()
            goto(pageIndex: shouldLoadReversed ? chapterImageURLs!.count-1:0, isDifferentChapter: true)
            chapterIndexButon.isEnabled = true
        }
    }
    
    // start preheating chapters images in the 'correct' order only ig preheater exists (when loading from remote source)
    func startPreheatingIfNecessary(){
        if let preheater = imagePreheater{
            let requests = chapterImageURLs!.map{Request(url: $0)}
            preheater.stopPreheating()
            preheater.startPreheating(with: shouldLoadReversed ? requests.reversed():requests)
        }
    }
    
    //Reactive: current-displaying chapter index
    var chapterIndex: Int!{
        didSet{
            navigationItem.title = chapterDataProvider[.name]
        }
    }
    
    // data provider current-displaying chapter
    var chapterDataProvider: ChapterDataProvider{
        return serieDataProvider.chapter(atIndex: chapterIndex, forState: .downloaded)
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
    
    
    private func setupUI(){
        dataSource = self
        delegate = self
        
        chapterIndexButon.target = self
        chapterIndexButon.action = #selector(showPagesSelector)
    }
    
    @objc func toggleFocus(){
        isFocused = !isFocused
    }
    
    // fetch image urls for current chapter
    private func fetchImageURLs(forChapterIndex index: Int){
        let oldIndex = chapterIndex
        chapterIndex = index
        
        // set chapterImageURLs right away for local source
        if let localChapter = chapterDataProvider as? MRChapter{
            chapterImageURLs = localChapter.sortedLocalImageURLs()
        }
        else{
            // load-from-remote style
            let blockingAlert = UIAlertController(title: "Loading Chapter Indexes", message: "", preferredStyle: .alert)
            navigationController?.present(blockingAlert, animated: false)
            chapterDataProvider.fetchImageURLs{urls in
                DispatchQueue.main.async {
                    if urls != nil{
                        blockingAlert.dismiss(animated: true)
                        self.chapterImageURLs = urls
                    }
                    else{
                        self.chapterIndex = oldIndex
                        blockingAlert.title = "Network Error"
                        blockingAlert.message = "Failed to load image-urls for chapter, please check your network connectivity."
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false){_ in
                            blockingAlert.dismiss(animated: true)
                        }
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
    private func goto(pageIndex: Int, isDifferentChapter: Bool = false){
        guard chapterImageURLs != nil else{
            return
        }
        // page flip like physical manga!
        let reversedFlipDirection: UIPageViewControllerNavigationDirection
        
        // if first flipping in new chapter, check for special cases
        if isDifferentChapter{
            // next chapter, flip forward
            if pageIndex == 0{
                reversedFlipDirection = .reverse
            }
                // last chapter, flip bakward
            else{
                reversedFlipDirection = .forward
            }
        }
        else{
            // flip forward if newIndex >= currentIndex
            reversedFlipDirection = pageIndex >= currentPageIndex ? .reverse:.forward
        }
        
        setViewControllers([ChapterImageViewController(dataProvider: chapterDataProvider, pageIndex: pageIndex, chapterIndex: chapterIndex)], direction: reversedFlipDirection, animated: true)
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
        if chapterImageURLs != nil{
            let sourceIndex = (viewController as! ChapterImageViewController).pageIndex!
            if sourceIndex+1 >= chapterImageURLs!.count{
                // load next chapter if exists
                let isLastChapter: Bool
                if serieDataProvider is MRSerie{
                    isLastChapter = chapterIndex+1 == serieDataProvider.numberOfChapters(ofState: .downloaded)
                }
                else{
                    isLastChapter = chapterIndex+1 == serieDataProvider[.chaptersCount]!
                }
                
                if !isLastChapter{
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
                return ChapterImageViewController(dataProvider: chapterDataProvider, pageIndex: sourceIndex+1, chapterIndex: chapterIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // does not do anything if this chapter has not loaded
        if chapterImageURLs != nil{
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
                return ChapterImageViewController(dataProvider: chapterDataProvider, pageIndex: sourceIndex-1, chapterIndex: chapterIndex)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if !isFocused{
            isFocused = true
        }
    }
    
}
