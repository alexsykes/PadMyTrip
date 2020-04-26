//
//  Track.swift
//  PadMyTrip
//
//  Created by Alex on 25/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Track: NSObject {
    // MARK: Properties
    var locations: [CLLocation]!
    var trackDescription: String
    var date: Date
    var region: MKCoordinateRegion!
    var name: String
    var style: String
    var north :Double = -90.0
    var south :Double = 90.0
    var west :Double = 180
    var east :Double = -180
    
    
    init(name :String, trackDescription: String, track: [CLLocation]) {
        self.trackDescription = trackDescription
        self.date = Date()
        self.locations = track
        self.name = name
        self.style = "default"
        
        super.init()
        self.region = calcBounds(track: track)
    }
    
    func calcBounds(track :[CLLocation]) -> MKCoordinateRegion {
        // var region :MKCoordinateRegion!
        // Latitude increases further north
        // Longitude increases further east
        var lat :Double!
        var long :Double!
        
        for location in track {
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            if lat > north { north = lat }
            if lat < south { south = lat }
            if long > east { east = long }
            if long < west { west = long }
        }
        let centreLat = (north + south)/2
        let centreLong = (east + west)/2
        let spanLong = 1.5 * (east - west)
        let spanLat = 1.5 * (north - south)
        
        // let northWest = CLLocationCoordinate2D(latitude: north, longitude: west)
        // let southEast = CLLocationCoordinate2D(latitude: south, longitude: east)
        let centre = CLLocationCoordinate2D(latitude: centreLat, longitude: centreLong)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
        
        let region = MKCoordinateRegion(center: centre, span: span)
        return region
    }
}