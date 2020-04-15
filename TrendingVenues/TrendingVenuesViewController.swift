//
//  TrendingVenuesViewController.swift
//  TrendingVenues
//
//  Created by Yuliyan Lyubenov on 11.04.20.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

class TrendingVenuesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: TrendingVenuesPresenter?
    var webRepo: TrendingVenuesWebRepository?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter = TrendingVenuesPresenter()
        self.webRepo = TrendingVenuesWebRepository()
        self.webRepo?.view = self.presenter
        self.presenter?.repository = webRepo
        self.presenter?.view = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presenter?.loadData()
    }
}

extension TrendingVenuesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfVenues() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath) as! VenueCell
        if let venue = self.presenter?.venueForIndexPath(indexPath: indexPath) {
            cell.titleLabel.text = venue.name
            cell.distanceLabel.text = self.presenter?.distanceFromVenue(venue: venue)
        }
        return cell
    }
    
    
}

extension TrendingVenuesViewController: TrendingVenuesView {
    func didUpdateVenuesData() {
        self.tableView.reloadData()
    }
    
    func didFailedUpdatingData(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true) {
            
        }
    }
}
