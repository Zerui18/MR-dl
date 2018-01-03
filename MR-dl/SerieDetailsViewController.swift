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
    
    static func `init`(dataProvider: SerieDataProvider)-> SerieDetailsViewController{
        let ctr = AppDelegate.shared.storyBoard.instantiateViewController(withIdentifier: storyboardID) as! SerieDetailsViewController
        ctr.serieDataProvider = dataProvider
        return ctr
    }
    
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstSeperatorView: UIView!
    
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: ReactiveThumbnailView!
    @IBOutlet weak var coverImageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailImageView: ReactiveThumbnailView!
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
    
    let refreshControl = UIRefreshControl()
    
    lazy var artworkURLs: [URL] = {
        return serieDataProvider[.artworkURLs]!
    }()
    let artworksPreheater = Preheater(manager: ThumbnailLoader.shared.imageLoaderManager, maxConcurrentRequestCount: 4)
    
    var serieDataProvider: SerieDataProvider!
    
    var isLocalSource: Bool{
        return serieDataProvider is MRSerie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
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
            self.statusBarStyle = .default
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        })
        self.isNavBarTransparent = false
        self.statusBarStyle = .default
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let artworkURLs: [URL] = serieDataProvider[.artworkURLs]!
        artworksPreheater.stopPreheating(with: artworkURLs.map(Request.init))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        artworksPreheater.stopPreheating()
    }
    
    
    private func setupUI(){
        scrollView.delegate = self
        refreshControl.tintColor = .white
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshSerie), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        refreshControl.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor).isActive = true
        refreshControl.centerXAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.centerXAnchor).isActive = true

        readButton.addTarget(self, action: #selector(showChaptersTable), for: .touchUpInside)
        toggleCollapseButton.addTarget(self, action: #selector(toggleCollapse), for: .touchUpInside)
        
        titleLabel.text = serieDataProvider[.name]
        thumbnailImageView.loadImage(fromURL: serieDataProvider[.thumbnailURL]!)
        
        authorLabel.text = serieDataProvider[.author]
        statusLabel.text = serieDataProvider[.statusDescription]
        updateDateLabel.text = serieDataProvider[.lastUpdatedDescription]
        
        let description: String = serieDataProvider[.serieDescription]!
        descriptionLabel.text = description
        descriptionHeightConstraint.constant = min(descriptionHeightConstraint.constant, description.height(forWidth: descriptionLabel.bounds.width, font: descriptionLabel.font))
        
        let coverURL: URL = serieDataProvider[.coverURL]!
        loadCoverImage(fromURL: coverURL)
        
        let artworkURLs: [URL] = serieDataProvider[.artworkURLs]!
        if !artworkURLs.isEmpty{
            artworksPreheater.startPreheating(with: artworkURLs.map(Request.init))
            artworksCollectionView.dataSource = self
        }
        else{
            artworksLabel.removeFromSuperview()
            artworksCollectionView.removeFromSuperview()
        }
        
        if isLocalSource{
            saveBarButton.isEnabled = false
        }
        else{
            saveBarButton.target = self
            saveBarButton.action = #selector(saveSerie)
        }
    }
    
    private func loadCoverImage(fromURL url: URL){
        coverImageView.loadImage(fromURL: url) { (image) in
            self.coverImageAspectRatioConstraint.isActive = false
            self.placeholderViewAspectRatioConstraint.isActive = false
            let widthToHeight = image.size.width / image.size.height
            self.coverImageView.widthAnchor.constraint(equalTo: self.coverImageView.heightAnchor, multiplier: widthToHeight).isActive =  true
            self.placeholderView.widthAnchor.constraint(equalTo: self.placeholderView.heightAnchor, multiplier: widthToHeight).isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func refreshSerie(){
        MRClient.getSerieMeta(forOid: serieDataProvider[.oid]!) {[weak self] (error, response) in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                if let meta = response?.data{
                    let dataProvider = strongSelf.serieDataProvider!
                    if let serie = dataProvider as? MRSerie{
                        serie.updateInfo(withMeta: meta)
                    }
                    else{
                        strongSelf.serieDataProvider = meta
                    }
                    strongSelf.statusLabel.text = dataProvider[.statusDescription]
                    strongSelf.updateDateLabel.text = dataProvider[.lastUpdatedDescription]
                    CoreDataHelper.shared.tryToSave()
                }
                else{
                    AppDelegate.shared.reportError(error: error!, ofCategory: "Load Serie")
                }
                strongSelf.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func saveSerie(){
        do{
            let localSerie = try LocalMangaDataSource.shared.createSerie(withMeta: serieDataProvider as! MRSerieMeta)
            serieDataProvider = localSerie
            saveBarButton.isEnabled = false
        }
        catch{
            AppDelegate.shared.reportError(error: error, ofCategory: "Save Serie")
        }
        
    }

    @objc private func showChaptersTable(){
        let chaptersTableCtr = ChaptersTableViewController(dataProvider: serieDataProvider)
        if navigationController!.navigationBar.isHidden{
            navigationController?.setNavigationBarHidden(false, animated: true)
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
        return artworkURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.identifier, for: indexPath) as! ArtworkCollectionViewCell
        cell.artworkURL = artworkURLs[indexPath.row]
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
