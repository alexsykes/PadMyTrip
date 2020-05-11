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
    func trackDetailUpdated(trackDetails: [String: String])
}

class TrackViewController: UIViewController, MKMapViewDelegate {
    var trackIndex :Int!
    var trackData :TrackData!
    var polyline :MKPolyline!
    var locs :[CLLocationCoordinate2D] = []
    
    
    weak var delegate: TrackDetailDelegate? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackID: UILabel!
    @IBOutlet weak var trackName: UITextField!
    
    @IBAction func updateTrackData(_ sender: Any) {
        var data  :[String: String] = [:]
        data["trackID"] = String(trackData._id)
        data["trackName"] = trackName.text!
        
        print ("Updated")
        
        delegate?.trackDetailUpdated(trackDetails: data)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        trackID.text = "Track ID: \(trackData._id)"
        trackName.text = trackData.name
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK:  Events
    // Plot currently active track when map loads
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
        // plotCurrentTrack()
    }
    
    // MARK: MapView functions
    // Render track on map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .purple
        renderer.lineWidth = 3
        // renderer.lineDashPattern = .some([4, 16, 16])
        
        return renderer
    }
}
