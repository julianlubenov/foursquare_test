//
//  TrendingVenuesWebRepository.swift
//  TrendingVenues
//
//  Created by User on 15.04.20.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class TrendingVenuesWebRepository : NSObject, TrendingVenuesRepository {
    
    weak var view: TrendingVenuesView?
    
    var locationManager:CLLocationManager?
    var userLocation: CLLocation?
    
    var updated: Bool = false
    var data: [VenueModel] = []
    
    static let trendingURL = "https://api.foursquare.com/v2/venues/explore"
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.delegate = self
    }
    
    func metersFromVenue(venue: VenueModel) -> Double? {
        return self.userLocation?.distance(from: CLLocation(latitude: venue.latitude, longitude: venue.longitude))
    }
    
    func numberOfVenues() -> Int {
        return self.data.count
    }
    
    func venueForIndex(index: Int) -> VenueModel? {
        if index < self.data.count {
            return self.data[index]
        }
        return nil
    }
    
    func loadData() {
        // First update once with the cached results from core data
        self.loadPersistentData()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    func loadPersistentData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
            do {
                let venues = try context.fetch(fetchRequest)
                var results: [VenueModel] = []
                for venue in venues {
                    let venueModel = VenueModel(name: venue.name, latitude: venue.latitude, longitude: venue.longitude)
                    results.append(venueModel)
                }
                if results.count > 0 {
                    results = results.sorted(by: { (ven1, ven2) -> Bool in
                        return (self.metersFromVenue(venue: ven1) ?? 0) < (self.metersFromVenue(venue: ven2) ?? 0)
                    })
                    self.data = results
                    self.view?.didUpdateVenuesData()
                }
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func afterLocationLoaded() {
        if (updated) {
            return
        }
        updated = true
        if let lat = self.userLocation?.coordinate.latitude, let lon = self.userLocation?.coordinate.longitude {
            let urlString = TrendingVenuesWebRepository.trendingURL + "?ll=\(lat),\(lon)&query=coffee&limit=10&client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)&v=\(Constants.foursquare_version)"
            if let url = URL(string: urlString) {
                let request = NSMutableURLRequest(url: url)
                let session = URLSession.shared
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                let task = session.dataTask(with: url, completionHandler: { data, response, error in
                    if let data = data {
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                            if let JSON = json as? [String: Any] {
                                if let resp = JSON["response"] as? [String: Any] {
                                    if let groups = resp["groups"] as? [[String: Any]], groups.count > 0 {
                                        if let items = groups[0]["items"] as? [Any] {
                                            print(items)
                                            
                                            var results: [VenueModel] = []
                                            for item in items {
                                                if let item = item as? [String: Any] {
                                                    if let item = item["venue"] as? [String: Any] {
                                                        let name = item["name"] as? String ?? ""
                                                        
                                                        let location = (item["location"] as? [String: Any]) ?? [:]
                                                        let lat = location["lat"] as? Double ?? 0
                                                        let lon = location["lng"] as? Double ?? 0
                                                        let venue = VenueModel(name: name, latitude: lat, longitude: lon)
                                                        results.append(venue)
                                                    }
                                                }
                                            }
                                            results = results.sorted(by: { (ven1, ven2) -> Bool in
                                                return (self.metersFromVenue(venue: ven1) ?? 0) < (self.metersFromVenue(venue: ven2) ?? 0)
                                            })
                                            DispatchQueue.main.async {
                                                self.data = results
                                                self.view?.didUpdateVenuesData()
                                                
                                                //Save data persistently
                                                self.saveDataPersisitently()
                                            }
                                            
                                            return;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        self.failedLoadingData()
                    }
                })
                task.resume()
            }
        }
    }
    
    func saveDataPersisitently() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            //Update persistent data only if there is some data
            if self.data.count > 0 {
                // First delete old data
                self.deleteOldData()
                
                // Save new data
                for venueModel in self.data {
                    if let entity = NSEntityDescription.insertNewObject(forEntityName: "Venue", into: context) as? Venue {
                        entity.name = venueModel.name
                        entity.latitude = venueModel.latitude
                        entity.longitude = venueModel.longitude
                        do {
                            try context.save()
                        } catch let error as NSError {
                          print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        }
    }
    
    func deleteOldData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
            do {
                let venues = try context.fetch(fetchRequest)
                for venue in venues {
                    context.delete(venue)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }

            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func failedLoadingData() {
        self.view?.didFailedUpdatingData(message: NSLocalizedString("Not connected to internat or no data currently available", comment: ""))
    }
    
    func failedLocation() {
        self.view?.didFailedUpdatingData(message: NSLocalizedString("Location services are not enabled", comment: ""))
    }
}

extension TrendingVenuesWebRepository: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            failedLocation()
            break
        case .denied:
            
            // If user denied your app access to Location Services, but can grant access from Settings.app
            failedLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation:CLLocation = locations.last {
            self.userLocation = userLocation
            self.afterLocationLoaded()
            
            // The user location updated so update the presentation
            self.view?.didUpdateVenuesData()
            
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

}
