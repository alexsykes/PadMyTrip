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
        
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        mapView.centerToLocation(initialLocation)
    }


}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
