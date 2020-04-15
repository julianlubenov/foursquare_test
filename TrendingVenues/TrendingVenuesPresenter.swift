//
//  TrendingVenuesPresenter.swift
//  TrendingVenues
//
//  Created by User on 14.04.20.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation

protocol TrendingVenuesView: AnyObject {
    func didUpdateVenuesData()
    func didFailedUpdatingData(message: String)
}

protocol TrendingVenuesRepository: AnyObject {
    func numberOfVenues() -> Int
    func venueForIndex(index: Int) -> VenueModel?
    func metersFromVenue(venue: VenueModel) -> Double?
    func loadData()
}

class TrendingVenuesPresenter {
    
    weak var view: TrendingVenuesView?
    weak var repository: TrendingVenuesRepository?
    
    init() {
    }
    
    func loadData() {
        self.repository?.loadData()
    }
    
    func numberOfVenues() -> Int {
        return self.repository?.numberOfVenues() ?? 0
    }
    
    func distanceFromVenue(venue: VenueModel) -> String {
        if let meters = self.repository?.metersFromVenue(venue: venue) {
            if meters > 1000.0 {
                return "\(Int(meters / 1000))km"
            } else {
                return "\(Int(meters))m"
            }
        }
        return ""
    }
    
    func venueForIndexPath(indexPath: IndexPath) -> VenueModel? {
        return self.repository?.venueForIndex(index: indexPath.row)
    }
    
}

extension TrendingVenuesPresenter: TrendingVenuesView {
    func didUpdateVenuesData() {
        self.view?.didUpdateVenuesData()
    }
    
    func didFailedUpdatingData(message: String) {
        self.view?.didFailedUpdatingData(message: message)
    }
}
