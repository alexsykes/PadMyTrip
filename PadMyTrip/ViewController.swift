//
//  ViewController.swift
//  PadMyTrip
//
//  Created by Alex on 24/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set initial location in Honolulu
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        getPermissions()
        setUpMap()
        
        writeOutputString(dataString: "Some data", fileName: "data", fileExtension: ".csv")
    }
    
    
     // MARK: Functions
    func setUpMap() {
        mapView.mapType = .standard
        // mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        // mapView.showsCompass = true
    }
    
    
    // Gets permisiions for location services
    func getPermissions() {
        // user activated automatic authorization info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: File Handling
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // let public = FileManager
        return paths[0]
    }
    
    func createDirectory () {
        let docDir = self.getDocumentsDirectory()
        let url = docDir.appendingPathComponent("MyFolderName")
        do {
            try FileManager.default.createDirectory(atPath: url.absoluteString, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func writeOutputString (dataString: String, fileName: String, fileExtension: String) {
        let longFileName = fileName + fileExtension
        
        let url = self.getDocumentsDirectory().appendingPathComponent(longFileName)
        
        do {
            try dataString.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //mapView.centerToLocation(location)
        let location = locations.last! as CLLocation
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
}
