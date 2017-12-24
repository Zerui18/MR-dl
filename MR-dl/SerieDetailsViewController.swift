//
//  SerieDetailsViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import MRClient

class SerieDetailsViewController: UIViewController{
    
    static let storyboardID = "serieDetailsCtr"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstSeperatorView: UIView!
    
    @IBOutlet weak var coverImageView: ZRImageView!
    @IBOutlet weak var coverImageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: ZRImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var readButton: ZRBorderedButton!
    @IBOutlet weak var detailsBox: UIView!
    @IBOutlet weak var toggleCollapseButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var descriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var artworksLabel: UILabel!
    @IBOutlet weak var artworksCollectionView: UICollectionView!
    
    
    var shortMeta: MRShortMeta!
    var serieMeta: MRSerieMeta?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.statusBarStyle = .lightContent
            self.isNavBarTransparent = true
            self.navBarItemsTintColor = .white
            self.tabBarController?.tabBar.isHidden = true
        })
        self.statusBarStyle = .lightContent
        self.isNavBarTransparent = true
        self.navBarItemsTintColor = .white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.statusBarStyle = .default
            self.isNavBarTransparent = false
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
            self.tabBarController?.tabBar.isHidden = false
        })
        self.statusBarStyle = .default
        self.isNavBarTransparent = false
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
    }
    
    private func setupUI(){
        scrollView.delegate = self
        thumbnailImageView.image = nil
        coverImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        statusLabel.text = nil
        updateDateLabel.text = nil
        readButton.isEnabled = false
        readButton.addTarget(self, action: #selector(showChaptersTable), for: .touchUpInside)
        toggleCollapseButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)
        
        titleLabel.text = shortMeta.name
        ThumbnailLoader.shared.loadImage(shortMeta.thumbnailURL!, intoTarget: thumbnailImageView)
        artworksCollectionView.dataSource = self
        
        if serieMeta == nil{
            fetchSerieMeta()
        }
        else{
            fillupMeta()
        }

    }

    private func fetchSerieMeta(){
        MRClient.getSerieMeta(forOid: shortMeta.oid, completion: {[weak self] (error, response) in
            if let `self` = self, let meta = response?.data{
                self.serieMeta = meta
                DispatchQueue.main.async {
                    self.fillupMeta()
                }
            }
        })
    }
    
    private func fillupMeta(){
        authorLabel.text = serieMeta!.author
        statusLabel.text = serieMeta!.statusDescription
        updateDateLabel.text = serieMeta!.lastUpdatedDescription
        descriptionLabel.text = serieMeta!.description
        descriptionHeightConstraint.constant = min(descriptionHeightConstraint.constant, serieMeta!.description.height(forWidth: descriptionLabel.bounds.width, font: descriptionLabel.font))
        readButton.isEnabled = true
        
        if !serieMeta!.artworkURLs.isEmpty{
            artworksCollectionView.reloadData()
        }
        else{
            artworksLabel.removeFromSuperview()
            artworksCollectionView.removeFromSuperview()
        }
        ThumbnailLoader.shared.loadImage(serieMeta!.coverURL, intoTarget: coverImageView){image in
            self.coverImageAspectRatioConstraint.isActive = false
            self.coverImageView.widthAnchor.constraint(equalTo: self.coverImageView.heightAnchor, multiplier: image.size.width/image.size.height).isActive =  true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func showChaptersTable(){
        let chaptersTableCtr = ChaptersTableViewController(withSerieMeta: serieMeta!)
        navigationController?.pushViewController(chaptersTableCtr, animated: true)
    }
    
    @objc private func toggleCollapse(){
        UIView.animate(withDuration: defaultAnimationDuration) {
            if self.descriptionHeightConstraint.isActive{
                self.toggleCollapseButton.transform = CGAffineTransform(rotationAngle: -.pi)
                self.descriptionHeightConstraint.isActive = false
            }
            else{
                self.toggleCollapseButton.transform = CGAffineTransform(rotationAngle: 0)
                self.descriptionHeightConstraint.isActive = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
}

extension SerieDetailsViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serieMeta?.artworkURLs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.identifier, for: indexPath) as! ArtworkCollectionViewCell
        cell.artworkURL = serieMeta!.artworkURLs[indexPath.row]
        return cell
    }
    
}

extension SerieDetailsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serieMeta?.chapters.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = serieMeta!.chapters[indexPath.row].name
        return cell!
    }
    
}

extension SerieDetailsViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isCoverShown = coverImageView.frame.maxY <= scrollView.contentOffset.y
        if let val = shouldHideStatusBar{
            if isCoverShown && val{
                UIView.animate(withDuration: defaultAnimationDuration, animations: {
                    self.shouldHideStatusBar = false
                })
            }
            else if !isCoverShown && !val{
                UIView.animate(withDuration: defaultAnimationDuration, animations: {
                    self.shouldHideStatusBar = true
                })
            }
        }
    }
    
}
