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
            print(response)
        })
    }
    
    private func processResponse(_ dictionary: [String: Any]) {
        guard let cityList = dictionary["list"] as? [Any] else {
            return
        }
        for (id, city) in cityList.enumerated() {
            guard let city = city as? [String: Any] else { return }
            let name = city["name"] ?? ""
            
            guard let weather = city["weather"] as? [String: Any] else { return }
            
            
        }
    }
    
    private func parseCity(_ dictionary: [String: Any]) {
        
    }
    
    
}
