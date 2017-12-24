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
import MRImageLoader

class ChapterImagesPageViewController: UIPageViewController {
    
    let imagePreheater = Preheater(manager: .shared, maxConcurrentRequestCount: 2)
    
    static func `init`(forSerie serieMeta: MRSerieMeta, atChapter chapterIndex: Int)-> ChapterImagesPageViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImagesCtr") as! ChapterImagesPageViewController
        ctr.serieMeta = serieMeta
        ctr.chapterIndex = chapterIndex
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
                self.viewControllers?[0].view.backgroundColor = self.isFocused ? .black:.white
            }
            navigationController?.setNavigationBarHidden(isFocused, animated: true)
        }
    }
    
    // current-displaying serie-meta
    var serieMeta: MRSerieMeta!
    
    //Reactive: chapterImageURLs for current-diplaying chapter
    var chapterImageURLs: [URL]?{
        didSet{
            currentPageIndex = 0
            imagePreheater.startPreheating(with: chapterImageURLs!.suffix(from: 1).map{Request(url: $0)})
            goto(pageIndex: 0)
            chapterIndexButon.isEnabled = true
            chapterIndexButon.title = "1/\(chapterImageURLs!.count)"
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
        fetchImageURLs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        imagePreheater.stopPreheating()
    }
    
    private func setupUI(){
        navigationItem.title = chapter.name
        dataSource = self
        delegate = self
        
        chapterIndexButon.target = self
        chapterIndexButon.action = #selector(showPagesSelector)
        
        let tapToFocusGetsure = UITapGestureRecognizer(target: self, action: #selector(toggleFocus))
        gestureRecognizers.forEach{
            tapToFocusGetsure.require(toFail: $0)
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFocus)))
    }
    
    @objc private func toggleFocus(){
        isFocused = !isFocused
    }
    
    
    // fetch image urls for current chapter
    private func fetchImageURLs(){
        chapterIndexButon.isEnabled = false
        chapterIndexButon.title = "Loading..."
        MRClient.getChapterImageURLs(forOid: chapter.oid) {[weak self] (error, response) in
            DispatchQueue.main.async {
                if let imageURLs = response?.data{
                    self?.chapterImageURLs = imageURLs
                }
                else{
                    self?.alert(title: "Network Error", message: "Failed to load image-urls for chapter, please check your network connectivity.")
                }
            }
        }
    }
    
    // present a picker view controller to jump to page
    @objc private func showPagesSelector(){
        let pickerController = ZRPickerViewController(options: [Int](1...chapterImageURLs!.count).map{"page \($0)"}, selected: currentPageIndex)
        pickerController.onSelection = {selectedIndex in
            self.goto(pageIndex: selectedIndex)
        }
        AppDelegate.shared.window?.rootViewController?.present(pickerController, animated: true)
    }
    
    // animate flip to specified page index
    private func goto(pageIndex: Int){
        guard let urls = chapterImageURLs else{
            return
        }
        let reversedDirection: UIPageViewControllerNavigationDirection = pageIndex >= currentPageIndex ? .reverse:.forward
        setViewControllers([ChapterImageViewController(imageURL: urls[pageIndex], pageIndex: pageIndex, chapterIndex: chapterIndex)], direction: reversedDirection, animated: true)
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
                    chapterIndex! += 1
                    fetchImageURLs()
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
                    chapterIndex! -= 1
                    fetchImageURLs()
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
    
}
