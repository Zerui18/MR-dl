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
        collectionView!.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:))))
    }
    
    @objc private func serieAddedNotification() {
        collectionView!.insertItems(at: [IndexPath(item: LocalMangaDataSource.shared.numberOfSeries-1, section: 0)])
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began, let indexPath = collectionView!.indexPathForItem(at: sender.location(in: collectionView!)) {
            let serie = LocalMangaDataSource.shared.series[indexPath.item]
            let alert = UIAlertController(title: "Actions", message: serie.name, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                try! LocalMangaDataSource.shared.deleteSerie(serie)
                self.collectionView!.deleteItems(at: [indexPath])
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }

}

extension SerieCollectionViewController {
    
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
