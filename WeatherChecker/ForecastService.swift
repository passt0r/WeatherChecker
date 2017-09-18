//
//  ForecastService.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
//TODO: perform download, parsing results, save data and perform reload of main screen

class ForecastService {
    private let coreDataStack: CoreDataStack!
    
    let apiEndpoint = "https://api.openweathermap.org/data/2.5/find?lat=%@&lon=%@&cnt=11&units=metric&appid=%@"
    
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func getWeather(forLatitude latitude: String, forLongitude longitude: String) {
        
        guard let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return
        }
        guard let infoPlistContent = NSDictionary(contentsOfFile: infoPath) else {
            return
        }
        guard let apiKey = infoPlistContent.object(forKey: "WeatherApiKey") as? String else {
            return
        }
        let requestString = String(format: apiEndpoint, latitude, longitude, apiKey)
        
        guard let apiRequest = URL(string: requestString) else {
            return
        }
        
       performRequest(withURL: apiRequest)
        
    }
    
    private func performRequest(withURL url: URL) {
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            guard let result = response.result.value as? [String: Any] else {
                return
            }
            self.deleteAllPreviousData()
            self.processResponse(result)
            self.coreDataStack.saveContext()
            
        })
    }
    
    private func deleteAllPreviousData() {
        let fetchCity = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        let fetchWeather = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        
        let requestCityDelete = NSBatchDeleteRequest(fetchRequest: fetchCity)
        let requestWeatherDelete = NSBatchDeleteRequest(fetchRequest: fetchWeather)
        
        do {
            try coreDataStack.managedContext.execute(requestWeatherDelete)
            try coreDataStack.managedContext.execute(requestCityDelete)
        } catch let error as NSError {
            print("Delete fetching error: \(error), \(error.userInfo)")
        }
    }
    
    private func processResponse(_ dictionary: [String: Any]) {
        guard let cityList = dictionary["list"] as? [Any] else {
            return
        }
        
        let newUpdateDate = Date()
        
        for (id, city) in cityList.enumerated() {
            //parse data from JSON
            guard let city = city as? [String: Any] else {
                return
            }
            let name = city["name"] as? String ?? ""
            
            guard let coordinates = city["coord"] as? [String: Any] else {
                return
            }
            
            let lat = coordinates["lat"] as? Double ?? 0.0
            let lon = coordinates["lon"] as? Double ?? 0.0
            
            guard let main = city["main"] as? [String:Any] else {
                return
            }
            let temperature = main["temp"] as? Int ?? 0
            
            guard let weather = city["weather"] as? [String: Any] else { return }
            let condition = weather["main"] as? String ?? ""
            let description = weather["description"] as? String ?? ""
            let iconName = weather["icon"] as? String ?? "default_weather"
            
            let newCity = City(context: coreDataStack.managedContext)
            newCity.name = name
            newCity.id = Int16(id)
            newCity.renewData = newUpdateDate as NSDate
            newCity.latitude = lat
            newCity.longtitude = lon
            
            let newWeather = Weather(context: coreDataStack.managedContext)
            newWeather.city = newCity
            newWeather.temperature = Int32(temperature)
            newWeather.condition = condition
            newWeather.conditionDescription = description
            newWeather.iconName = iconName
        }
    }
    
    
}
