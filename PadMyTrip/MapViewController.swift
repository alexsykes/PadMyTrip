//
//  MapViewController.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var trackTableViewController :TrackTableViewController?
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        trackTableViewController = TrackTableViewController(nibName: "trackTableViewController", bundle: nil)
        setUpMap()
    }

    func setup(string text: String) {
        print(text)
    }
    
    func setUpMap() {
      self.mapView.mapType = .standard
    }
}
