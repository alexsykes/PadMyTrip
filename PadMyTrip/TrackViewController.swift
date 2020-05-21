//
//  TrackViewController.swift
//  PadMyTrip
//
//  Created by Alex on 06/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol TrackDetailDelegate: AnyObject {
    func trackDetailUpdated(trackDetails: [String: String], isTrackIncluded: Bool)
}

class TrackViewController: UIViewController, MKMapViewDelegate {
    var trackIndex :Int!
    var trackData :TrackData!
    var isTrackIncluded: Bool!
    var polyline :MKPolyline!
    var locs :[CLLocationCoordinate2D] = []
    var data  :[String: String] = [:]
    var mapType: Int = 0
    
    
    weak var delegate: TrackDetailDelegate? = nil
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackID: UILabel!
    @IBOutlet weak var trackName: UITextField!
    @IBOutlet weak var isTrackIncludedSwitch: UISwitch!
    @IBOutlet weak var lineStyleSelect: UISegmentedControl!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    
    @IBAction func updateTrackData(_ sender: Any) {
        data["trackID"] = String(trackData._id)
        data["trackName"] = trackName.text
        let lineStyle = lineStyleSelect.selectedSegmentIndex
        data["lineStyle"] = String(lineStyle)
        print ("Updated")
        
        delegate?.trackDetailUpdated(trackDetails: data, isTrackIncluded: isTrackIncludedSwitch.isOn)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mapTypeSelected(_ sender: UISegmentedControl) {
        mapType = sender.selectedSegmentIndex
        switch mapType {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    
    @IBAction func nameDidChange(_ sender: UITextField) {
        data["trackName"] = trackName.text
        print("nameDidChange")
        
        delegate?.trackDetailUpdated(trackDetails: data, isTrackIncluded: isTrackIncludedSwitch.isOn)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func styleDidChange(_ sender: Any) {
        // Change line style
        print("Styles has changed to: ")
        
        // Reload map
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        switch mapType {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
        mapTypeSelector.selectedSegmentIndex = mapType
        
        trackID.text = "Track ID: \(trackData._id)"
        isTrackIncludedSwitch.isOn = trackData.isVisible
        trackName.text = trackData.name
        lineStyleSelect.selectedSegmentIndex = trackData.style
        let trackPoints = trackData.points.count
        if trackPoints == 0 {
            print("Track has \(trackPoints) points")
            return
        }
        for point in trackData.points {
            let location = CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
            locs.append(location)
        }
        
        let polyline = MKPolyline(coordinates: locs, count: locs.count)
        mapView.addOverlay(polyline)
        mapRefresh()
        
        // Do any additional setup after loading the view.
        print("ViewDidLoad")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        updateTrackData(self)
    }
    func mapRefresh() {
        // Calculate map region then apply
        var northMost = -90.0
        var southMost = 90.0
        var eastMost = -180.0
        var westMost = 180.0
        
        for point in locs {
            let lat = point.latitude
            let long = point.longitude
            
            if lat > northMost { northMost = lat }
            if lat < southMost { southMost = lat }
            if long > eastMost { eastMost = long }
            if long < westMost { westMost = long }
        }
        
        let centreLat = (northMost + southMost)/2
        let centreLong = (eastMost + westMost)/2
        let spanLong = 1.5 * (eastMost - westMost)
        let spanLat = 1.5 * (northMost - southMost)
        
        let centre = CLLocationCoordinate2D(latitude: centreLat, longitude: centreLong)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
        let region = MKCoordinateRegion(center: centre, span: span)
        mapView.region = region
        
    }
    
    // MARK:  Events
    // Plot currently active track when map loads
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
        // plotCurrentTrack()
    }
    
    // MARK: MapView functions
    // Render track on map
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor.gray
//        renderer.lineWidth = 3
//        renderer.lineDashPattern = [4,16,4,8]
//        return renderer
//    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
           if overlay is RoadOverlay {
               renderer.strokeColor = UIColor.black
               renderer.alpha = 1
               renderer.lineWidth = 3
             //  renderer.lineDashPattern = [4,16,4,8]
               
           } else if overlay is TrackOverlay {
               renderer.strokeColor = .black
               renderer.lineWidth = 2
              // renderer.lineDashPattern = [16,8,8,8]
             //  renderer.lineDashPhase = 12
               
           } else if overlay is PathOverlay {
               renderer.strokeColor = .brown
               renderer.lineWidth = 2
               renderer.lineDashPattern = [16,8]
               renderer.lineDashPhase = 8
               
           } else if overlay is SmallPathOverlay {
               renderer.strokeColor = .brown
               renderer.lineWidth = 2
               renderer.lineDashPattern = [8,88]
               renderer.lineDashPhase = 4
               
           } else {
               renderer.strokeColor = UIColor.red
               renderer.lineWidth = 5
           }
           return renderer
       }
    
    class RoadOverlay: MKPolyline{
    }
    class TrackOverlay: MKPolyline{
    }
    class PathOverlay: MKPolyline{
    }
    class SmallPathOverlay: MKPolyline{
    }
    
}
