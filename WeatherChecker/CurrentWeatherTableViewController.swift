//
//  CurrentWeatherTableViewController.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentWeatherTableViewController: UITableViewController {
    
    let currentCityCellIdentifier = "CurrentCityCell"
    let localCityCellIdentifier = "LocalCityCell"
    let updatingCellIdentifier = "UpdatingCell"
    
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var timer: Timer?
    var location: CLLocation?
    
    var coreDataStack: CoreDataStack!
    var fetchedResultController: NSFetchedResultsController<City>!
    
    var forecast: ForecastService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFetchController()
        fetchedResultController.delegate = self
        forecast = ForecastService(coreDataStack: coreDataStack)
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(getLocation), for: .valueChanged)
        refreshControll.attributedTitle = NSAttributedString(string: NSLocalizedString("Updating weather info...", comment: "Refresh controll message"))
        tableView.refreshControl = refreshControll
        
        getLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLocation()
    }
    
    func prepareFetchController() {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(City.id), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: "CityWeather")
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       guard let sectionInfo = fetchedResultController.sections?[section] else { return 0 }
        if section == 0 && sectionInfo.numberOfObjects == 0 {
            return 1
        }
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if no data was previous downloaded, than show Loading cell
        if tableView.numberOfRows(inSection: 0) == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: updatingCellIdentifier, for: indexPath)
            
            return cell
        }
        
        if indexPath.row == 0 {
            return configureThisCityCell(at: indexPath)
        } else {
            return configureLocalCityCell(at: indexPath)
        }
        
    }
    
    private func configureThisCityCell(at indexPath: IndexPath) -> CurrentCityTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCityCellIdentifier, for: indexPath) as! CurrentCityTableViewCell
        //TODO: configure cell
        let currentCity = fetchedResultController.object(at: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        cell.statusLabel.text = String(format: "Update at: %@", dateFormatter.string(from: currentCity.renewData! as Date))
        
        cell.cityNameLabel.text = currentCity.name ?? NSLocalizedString("Unnown", comment: "Unnown city description")
        cell.tempLabel.text = "\(String(describing: currentCity.weather!.temperature))°C"
        cell.weatherDescriptionLabel.text = currentCity.weather?.conditionDescription
        
        guard let conditionIconName = currentCity.weather?.iconName else { return cell }
        guard let conditionIcon = UIImage(named: conditionIconName) else { return cell }
        cell.weatherIconView.image = conditionIcon
        return cell
    }
    
    private func configureLocalCityCell(at indexPath: IndexPath) -> LocalCityTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: localCityCellIdentifier, for: indexPath) as! LocalCityTableViewCell
        //TODO: configure cell
        let currentCity = fetchedResultController.object(at: indexPath)
        
        cell.cityNameLabel.text = currentCity.name ?? NSLocalizedString("Unnown", comment: "Unnown city description")
        cell.tempLabel.text = "\(String(describing: currentCity.weather!.temperature))°C"
        cell.weatherDescriptionLabel.text = currentCity.weather?.conditionDescription
        
        guard let conditionIconName = currentCity.weather?.iconName else { return cell }
        guard let conditionIcon = UIImage(named: conditionIconName) else { return cell }
        cell.weatherIconView.image = conditionIcon
        return cell

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CurrentWeatherTableViewController: CLLocationManagerDelegate {
    func getLocation() {
        if Reachability.isInternetAvailable() {
            performLocationSearch()
        } else {
            stopRefreshing()
        }
    }
    
    func performLocationSearch() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .restricted || authStatus == .denied{
            showLocationManagerAlert()
            return
        }
        startLocationManager()
    }
    
    func stopRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            updatingLocation = true
            locationManager.startUpdatingLocation()
            
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func didTimeOut() {
        print("*** Time out")
        stopRefreshing()
        if location == nil {
            stopLocationManager()
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
            //perform update only if new search was perform
            performWeatherUpdate()
        }
    }
    
    func showLocationManagerAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Location Services Disabled", comment: "Location Services Disabled Allert title"), message: NSLocalizedString("Please enable location services for this app in Settings.", comment: "Location Services Disabled Allert message"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //if location unknown just keep try
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        stopLocationManager()
        print("didFailWithError \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       guard let newLocation = locations.last else { return }
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if self.location == nil ||
            self.location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            self.location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
            
            if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 8 {
                    print("*** Force done!")
                    stopLocationManager()
                }
            }
        }
    }
}

//MARK: -Perform searching weather data
extension CurrentWeatherTableViewController {
    func performWeatherUpdate() {
        guard let newLocation = location else {
            return
        }
        let latitude = String(format: "%.2f", newLocation.coordinate.latitude)
        let longitude = String(format: "%.2f", newLocation.coordinate.longitude)
        
        forecast.getWeather(forLatitude: latitude, forLongitude: longitude)
        
        //delete previous find location
        location = nil
    }

}

extension CurrentWeatherTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //TODO: this is works, but it is not solution, it's for time
        do {
            try controller.performFetch()
        } catch let error as NSError {
            print("Update error: \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        stopRefreshing()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
