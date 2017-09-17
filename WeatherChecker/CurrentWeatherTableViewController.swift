//
//  CurrentWeatherTableViewController.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentWeatherTableViewController: UITableViewController {
    
    let currentCityCellIdentifier = "CurrentCityCell"
    let localCityCellIdentifier = "LocalCityCell"
    
    let locationManager = CLLocationManager()
    var updatingLocation = false
    var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
            //TODO: Delete all previous location, save new and renew interface
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
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        updatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            performWeatherUpdate()
        }
    }
    
    func performWeatherUpdate() {
        guard let newLocation = location else {
            return
        }
        let latitude = String(format: "%.2f", newLocation.coordinate.latitude)
        let longitude = String(format: "%.2f", newLocation.coordinate.longitude)
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
        
        var distance = CLLocationDistance(DBL_MAX)
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
