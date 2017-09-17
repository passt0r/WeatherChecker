//
//  DataSource.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import Foundation
import CoreData

class DataSource {
    private let coreDataStack: CoreDataStack
    
    var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>!
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
