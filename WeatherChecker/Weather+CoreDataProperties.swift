//
//  Weather+CoreDataProperties.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var temperature: Int32
    @NSManaged public var condition: String?
    @NSManaged public var conditionIcon: NSData?
    @NSManaged public var conditionDescription: String?
    @NSManaged public var iconName: String?
    @NSManaged public var city: City?

}
