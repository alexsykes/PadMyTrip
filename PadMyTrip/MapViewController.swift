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
import CoreData
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    var polylines :[MKPolyline] = []
    var container: NSPersistentContainer!
    var trackIndex: Int!
    
    // MARK: Properties
    var locationManager: CLLocationManager!
   // var trackTableViewController :TrackTableViewController?
    var currentMap: Map!
    var trackData:[TrackData]!
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard container != nil else {
//            fatalError("This view needs a persistent container.")
//        }
        // The persistent container is available.
        
        
        mapView.delegate = self
     //   trackTableViewController = TrackTableViewController(nibName: "trackViewController", bundle: nil)
        currentMap = Map(name: "Line 38", mapDescription: "Line 38 description")
        setUpMap()
        print("Track index: \(trackIndex)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(false)
       // trackData.removeAll()
        currentMap = nil
        mapView.removeOverlays(polylines)
        mapView.delegate = nil
        mapView = nil
    }
    
//    deinit {
//       // currentMap = nil
//        mapView.delegate = nil
//        mapView = nil
//          currentMap = nil
//    }
    


    func displayTrack(trackData: TrackData) {
        
        var locations : [CLLocation] = []
        let name = trackData.name
        let description = "A track"
        var points = trackData.points
        for point in points {
            let lat = point.lat
            let long = point.long
            let location = CLLocation(latitude: lat, longitude: long)
            locations.append(location)
        }
       
        let track :Track = Track(name: name, trackDescription: description, track: locations)
        
        self.currentMap.addTrack(track: track)
        let region = self.currentMap.calcBounds()
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polylines)
    }
    
    func setUpMap() {
      self.mapView.mapType = .standard
    }
}
