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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.isNavBarTransparent = false
            self.statusBarStyle = .default
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        })
        self.isNavBarTransparent = false
        self.statusBarStyle = .default
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
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
            saveBarButton.target = self
            saveBarButton.action = #selector(showDownloadsTable)
            titleLabel.text = localSerie!.name
            thumbnailImageView.loadImage(withLoader: ThumbnailLoader.shared, fromURL: localSerie!.thumbnailURL!)
            fillupMeta()
        }
        else{
            if LocalMangaDataSource.shared.hasSerie(withOid: shortMeta.oid){
                saveBarButton.isEnabled = false
            }
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
        let author: String, status: String, updated: String, description: String, coverURL: URL, artworkURLs: [URL]
        if isLocalSource{
            author = localSerie!.author!
            status = localSerie!.statusDescription
            updated = localSerie!.lastUpdatedDescription
            description = localSerie!.serieDescription!
            coverURL = localSerie!.coverURL!
            artworkURLs = localSerie!.artworkURLs!
        }
        else{
            author = serieMeta!.author
            status = serieMeta!.statusDescription
            updated = serieMeta!.lastUpdatedDescription
            description = serieMeta!.description
            coverURL = serieMeta!.coverURL
            artworkURLs = serieMeta!.artworkURLs
        }
        authorLabel.text = author
        statusLabel.text = status
        updateDateLabel.text = updated
        descriptionLabel.text = description
        descriptionHeightConstraint.constant = min(descriptionHeightConstraint.constant, description.height(forWidth: descriptionLabel.bounds.width, font: descriptionLabel.font))
        readButton.isEnabled = true
        loadCoverImage(fromURL: coverURL)
        
        if !artworkURLs.isEmpty{
            if navigationController?.visibleViewController == self{
                artworksPreheater.startPreheating(with: artworkURLs.map{Request(url: $0)})
            }
            artworksCollectionView.reloadData()
        }
        else{
            artworksLabel.removeFromSuperview()
            artworksCollectionView.removeFromSuperview()
        }
        
        if !isLocalSource{
            saveBarButton.target = self
            saveBarButton.action = #selector(saveSerie)
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
        do{
            let localSerie = try LocalMangaDataSource.shared.createSerie(withMeta: serieMeta!)
            localSerie.downloader.beginDownload()
            saveBarButton.isEnabled = false
        }
        catch{
            AppDelegate.shared.reportError(error: error, ofCategory: "Save Serie")
        }
        
    }
    
    @objc private func showDownloadsTable(){
        let tableCtr = ChapterDownloadsTableViewController(serie: localSerie!)
        navigationController?.pushViewController(tableCtr, animated: true)
    }
    
    @objc private func showChaptersTable(){
        let chaptersTableCtr: ChaptersTableViewController
        if isLocalSource{
            chaptersTableCtr = ChaptersTableViewController(withSerie: localSerie!)
        }
        else{
            chaptersTableCtr = ChaptersTableViewController(withSerieMeta: serieMeta!)
        }
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
        return isLocalSource ? localSerie!.artworkURLs!.count:serieMeta?.artworkURLs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.identifier, for: indexPath) as! ArtworkCollectionViewCell
        cell.artworkURL = (isLocalSource ? localSerie!.artworkURLs!:serieMeta!.artworkURLs)[indexPath.row]
        return cell
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
