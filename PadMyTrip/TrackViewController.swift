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

class TrackViewController: UIViewController, MKMapViewDelegate {
    var trackIndex :Int!
    var track :TrackData!
    var polyline :MKPolyline!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        

   //     polyline = track.getPolyline()
  //      mapView.addOverlay(polyline)
  //      let region :MKCoordinateRegion = track.region
   //     mapView.region = region
        // Do any additional setup after loading the view.
        print("ViewDidLoad")
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
