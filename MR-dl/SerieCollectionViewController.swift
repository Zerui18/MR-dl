//
//  SerieCollectionViewController.swift
//  MR-dl
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import MRClient
import ImageLoader

class SerieCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(serieAddedNotification), name: .serieAddedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.isNavBarTransparent = false
            self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
            self.statusBarStyle = .default
        })
        self.isNavBarTransparent = false
        self.navBarItemsTintColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1)
        self.statusBarStyle = .default
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func serieAddedNotification(){
        collectionView!.insertItems(at: [IndexPath(item: LocalMangaDataSource.shared.numberOfSeries-1, section: 0)])
    }

}

extension SerieCollectionViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LocalMangaDataSource.shared.numberOfSeries
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SerieCollectionViewCell.identifier, for: indexPath) as! SerieCollectionViewCell
        cell.serie = LocalMangaDataSource.shared.series[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let serie = (collectionView.cellForItem(at: indexPath) as! SerieCollectionViewCell).serie!
        let ctr = SerieDetailsViewController(dataProvider: serie)
        navigationController!.pushViewController(ctr, animated: true)
    }
    
}
