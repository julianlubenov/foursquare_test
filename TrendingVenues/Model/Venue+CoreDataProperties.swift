//
//  Venue+CoreDataProperties.swift
//  TrendingVenues
//
//  Created by User on 15.04.20.
//  Copyright © 2020 None. All rights reserved.
//
//

import Foundation
import CoreData


extension Venue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venue> {
        return NSFetchRequest<Venue>(entityName: "Venue")
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}
