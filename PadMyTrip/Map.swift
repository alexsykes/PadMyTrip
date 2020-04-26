//
//  Map.swift
//  PadMyTrip
//
//  Created by Alex Sykes on 25/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Map: NSObject {
    // MARK: Properties
    var tracks: [Track]!
    var mapDescription: String
    var date: Date
    var region: MKCoordinateRegion!
    var name: String
    var styles: [String]
    var north :Double = -90.0
    var south :Double = 90.0
    var west :Double = 180
    var east :Double = -180
    
    init(name :String, mapDescription: String, tracks: [Track]) {
        self.mapDescription = mapDescription
        self.date = Date()
        self.tracks = tracks
        self.name = name
        self.styles = ["default"]
        
        super.init()
        self.region = calcBounds(tracks: tracks)
    }
    
    func calcBounds( tracks: [Track]) -> MKCoordinateRegion {
        let northwest = CLLocationCoordinate2D(latitude: 0.00,longitude: 90.0)
        let southeast = CLLocationCoordinate2D(latitude: 0.00,longitude: 90.0)
        let region = MKCoordinateRegion(    }
    return region
}
