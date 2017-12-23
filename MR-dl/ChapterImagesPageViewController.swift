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
    
    static func `init`(forSerie serieMeta: MRSerieMeta, atChapter chapterIndex: Int)-> ChapterImagesPageViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: "chapterImagesCtr") as! ChapterImagesPageViewController
        ctr.serieMeta = serieMeta
        ctr.chapterIndex = chapterIndex
        return ctr
    }
    
    static weak var shared: ChapterImagesPageViewController?
    
    @IBOutlet weak var chapterIndexButon: UIBarButtonItem!
    
    var serieMeta: MRSerieMeta!
    
    var chapterImageURLs: [URL]?{
        didSet{
            self.currentPageIndex = 0
            goto(pageIndex: 0)
            chapterIndexButon.isEnabled = true
            chapterIndexButon.title = "1/\(chapterImageURLs!.count)"
        }
    }
    
    var chapterIndex: Int!{
        didSet{
            navigationItem.title = chapter.name
        }
    }
    var chapter: MRSerieMeta.ChapterMeta{
        return serieMeta.chapters[chapterIndex]
    }
    
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
    
    private func setupUI(){
        navigationItem.title = chapter.name
        dataSource = self
        
        chapterIndexButon.target = self
        chapterIndexButon.action = #selector(showPagesSelector)
        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDarkMode)))
    }
    
//    @objc func toggleDarkMode(){
//        UIView.animate(withDuration: 0.4) {
//            if self.presentedViewController!.backgroundColor == .white{
//
//            }
//            else{
//
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // fetch image urls for current chapter
    private func fetchImageURLs(){
        chapterIndexButon.isEnabled = false
        chapterIndexButon.title = "Loading..."
        MRClient.getChapterImageURLs(forOid: chapter.oid) {[weak self] (error, response) in
            if let imageURLs = response?.data{
                DispatchQueue.main.async {
                    self?.chapterImageURLs = imageURLs
                }
            }
        }
    }
    
    @objc private func showPagesSelector(){
        let pickerController = ZRPickerViewController(options: [Int](1...chapterImageURLs!.count).map{"page \($0)"}, selected: currentPageIndex)
        pickerController.onSelection = {selectedIndex in
            self.goto(pageIndex: selectedIndex)
        }
        AppDelegate.shared.window?.rootViewController?.present(pickerController, animated: true)
    }
    
    private func goto(pageIndex: Int){
        guard let urls = chapterImageURLs else{
            return
        }
        let reversedDirection: UIPageViewControllerNavigationDirection = pageIndex >= currentPageIndex ? .reverse:.forward
        setViewControllers([ChapterImageViewController(imageURL: urls[pageIndex], pageIndex: pageIndex, chapterIndex: chapterIndex)], direction: reversedDirection, animated: true)
    }

}

extension ChapterImagesPageViewController: UIPageViewControllerDataSource{
    
    func alert(message: String){
        let alertCtr = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
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
                    alert(message: "This is already the last chapter!")
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
                    alert(message: "This is already the first chapter!")
                }
            }
            else{
                // load prev page
                return ChapterImageViewController(imageURL: urls[sourceIndex-1], pageIndex: sourceIndex-1, chapterIndex: chapterIndex)
            }
        }
        return nil
    }
    
}
