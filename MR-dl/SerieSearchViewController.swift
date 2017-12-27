//
//  MangaSearchViewController.swift
//  MR-dl
//
//  Created by Chen Zerui on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit
import CustomUI
import MRClient

class SerieSearchViewController: UITableViewController{
    
    var shortMetas: [String:MRShortMeta] = [:]
    
    var serieSearchResults = [String](){
        didSet{
            guard serieSearchResults != oldValue else{
                return
            }
            
            shortMetas.removeAll()
            self.tableView.reloadData()
            
            guard !serieSearchResults.isEmpty else{
                return
            }
            
            let query = self.query
            MRClient.getMetas(forOids: self.serieSearchResults, completion: { (error, response) in
                if let metaDict = response?.data, query == self.query{
                    self.shortMetas = metaDict
                    DispatchQueue.main.async {
                        for (oid, meta) in metaDict{
                            if let index = self.serieSearchResults.index(of: oid), let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SerieTableViewCell{
                                cell.shortMeta = meta
                            }
                        }
                    }
                }
            })
            
        }
    }
    
    var query = ""
    var resultUpdateTimer = Timer()
    
    lazy var searchActiveIndicator = NVActivityIndicatorView(frame: CGRect(x: 150, y: 200, width: 55, height: 55), type: .balls, color:  #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    }

    private func setupUI(){
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIView()

        searchActiveIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView!.addSubview(searchActiveIndicator)
        
        searchActiveIndicator.centerXAnchor.constraint(equalTo: tableView.backgroundView!.centerXAnchor).isActive = true
        searchActiveIndicator.topAnchor.constraint(equalTo: tableView.contentLayoutGuide.topAnchor, constant: 30).isActive = true
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serieSearchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SerieTableViewCell.identifier) as! SerieTableViewCell
        cell.oid = serieSearchResults[indexPath.row]
        if let meta = shortMetas[cell.oid]{
            cell.shortMeta = meta
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (tableView.cellForRow(at: indexPath) as! SerieTableViewCell).shortMeta != nil ? indexPath:nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SerieTableViewCell
        let detailsCtr = SerieDetailsViewController.init(shortMeta: cell.shortMeta!, serieMeta: cell.serieMeta)
        navigationItem.searchController?.isActive = false
        navigationController!.pushViewController(detailsCtr, animated: true)
    }
    
}

extension SerieSearchViewController: UISearchResultsUpdating, UISearchBarDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        resultUpdateTimer.invalidate()
        if let query = searchController.searchBar.text, !query.isEmpty{
            resultUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                self.quickSearch(query: query)
            })
        }
        else{
            serieSearchResults = []
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultUpdateTimer.invalidate()
        serieSearchResults = []
        if let query = searchBar.text, !query.isEmpty{
            self.completeSearch(query: query)
        }
    }
    
    private func quickSearch(query: String){
        self.query = query
        searchActiveIndicator.startAnimating()
        MRClient.quickSearch(forQuery: query) { (error, response) in
            if self.query == query, let response = response{
                DispatchQueue.main.async {
                    self.searchActiveIndicator.stopAnimating()
                    self.serieSearchResults = response.data["series"] ?? []
                }
            }
        }
    }
    
    private func completeSearch(query: String){
        self.query = query
        searchActiveIndicator.startAnimating()
        MRClient.completeSearch(forQuery: query, category: .series) { (error, response) in
            if self.query == query{
                DispatchQueue.main.async {
                    self.searchActiveIndicator.stopAnimating()
                    self.serieSearchResults = response!.data
                }
            }
        }
    }
    
}
