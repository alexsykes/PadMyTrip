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

class TrackViewController: UIViewController {
    var trackIndex :Int!
    var track :Track!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region :MKCoordinateRegion = track.region
        mapView.region = region

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
