//
//  SerieDetailsViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 21/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import ImageLoader
import CustomUI
import MRClient

class SerieDetailsViewController: UIViewController{
    
    static let storyboardID = "serieDetailsCtr"
    
    static func `init`(shortMeta: MRShortMeta, serieMeta: MRSerieMeta?)-> SerieDetailsViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: storyboardID) as! SerieDetailsViewController
        ctr.shortMeta = shortMeta
        ctr.serieMeta = serieMeta
        return ctr
    }
    
    static func `init`(localSerie: MRSerie)-> SerieDetailsViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: storyboardID) as! SerieDetailsViewController
        ctr.localSerie = localSerie
        return ctr
    }
    
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstSeperatorView: UIView!
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: ZRReactiveImageView!
    @IBOutlet weak var coverImageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: ZRReactiveImageView!
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
    
    let artworksPreheater = Preheater(manager: ThumbnailLoader.shared.imageLoaderManager, maxConcurrentRequestCount: 4)
    
    var shortMeta: MRShortMeta!
    var serieMeta: MRSerieMeta?
    
    var localSerie: MRSerie?
    
    var isLocalSource: Bool{
        return localSerie != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.isNavBarTransparent = true
            self.navBarItemsTintColor = .white
            self.statusBarStyle = .lightContent
        })
        self.isNavBarTransparent = true
        self.navBarItemsTintColor = .white
        self.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLocalSource{
            artworksPreheater.startPreheating(with: localSerie!.artworkURLs!.map(Request.init))
        }
        else if let urls = serieMeta?.artworkURLs{
            artworksPreheater.startPreheating(with: urls.map(Request.init))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        artworksPreheater.stopPreheating()
    }
    
    
    private func setupUI(){
        scrollView.delegate = self
        thumbnailImageView.image = nil
        coverImageView.image = nil
        descriptionLabel.text = nil
        statusLabel.text = nil
        updateDateLabel.text = nil
        readButton.isEnabled = false
        readButton.addTarget(self, action: #selector(showChaptersTable), for: .touchUpInside)
        toggleCollapseButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)
        artworksCollectionView.dataSource = self
        
        if isLocalSource{
            (saveBarButton.value(forKey: "_view") as! UIView).removeFromSuperview()
            titleLabel.text = localSerie!.name
            thumbnailImageView.loadImage(withLoader: ThumbnailLoader.shared, fromURL: localSerie!.thumbnailURL!)
            loadCoverImage(fromURL: localSerie!.coverURL!)
        }
        else{
            titleLabel.text = shortMeta.name
            thumbnailImageView.loadImage(withLoader: ThumbnailLoader.shared, fromURL: shortMeta.thumbnailURL!)
            
            if serieMeta == nil{
                fetchSerieMeta()
            }
            else{
                fillupMeta()
            }
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
        let author: String, status: String, updated: String, description: String
        if isLocalSource{
            author = localSerie!.author!
            status = localSerie!.statusDescription
            updated = localSerie!.lastUpdatedDescription
            description = localSerie!.serieDescription!
        }
        else{
            author = serieMeta!.author
            status = serieMeta!.statusDescription
            updated = serieMeta!.lastUpdatedDescription
            description = serieMeta!.description
        }
        authorLabel.text = author
        statusLabel.text = status
        updateDateLabel.text = updated
        descriptionLabel.text = description
        descriptionHeightConstraint.constant = min(descriptionHeightConstraint.constant, serieMeta!.description.height(forWidth: descriptionLabel.bounds.width, font: descriptionLabel.font))
        readButton.isEnabled = true
        
        if !isLocalSource{
            saveBarButton.target = self
            saveBarButton.action = #selector(saveSerie)
            if !serieMeta!.artworkURLs.isEmpty{
                if navigationController?.visibleViewController == self{
                    artworksPreheater.startPreheating(with: serieMeta!.artworkURLs.map{Request(url: $0)})
                }
                artworksCollectionView.reloadData()
            }
            else{
                artworksLabel.removeFromSuperview()
                artworksCollectionView.removeFromSuperview()
            }
            loadCoverImage(fromURL: serieMeta!.coverURL)
        }
        
    }
    
    private func loadCoverImage(fromURL url: URL){
        coverImageView.loadImage(withLoader: ThumbnailLoader.shared, fromURL: url) { (image) in
            self.coverImageAspectRatioConstraint.isActive = false
            self.placeholderViewAspectRatioConstraint.isActive = false
            let widthToHeight = image.size.width / image.size.height
            self.coverImageView.widthAnchor.constraint(equalTo: self.coverImageView.heightAnchor, multiplier: widthToHeight).isActive =  true
            self.placeholderView.widthAnchor.constraint(equalTo: self.placeholderView.heightAnchor, multiplier: widthToHeight).isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func saveSerie(){
        let localSerie = try! LocalMangaDataSource.shared.createSerie(withMeta: serieMeta!)
        
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
        let shouldShowNavigationBar = scrollView.contentOffset.y < 50
        if shouldShowNavigationBar && (navigationController?.isNavigationBarHidden ?? false){
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        else if !shouldShowNavigationBar && !(navigationController?.isNavigationBarHidden ?? true){
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
}
