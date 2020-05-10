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
    var _id :Int
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
    
    static var serial :Int = 0
    init(name :String, trackDescription: String, track: [CLLocation]) {
        self.trackDescription = trackDescription
        self.date = Date()
        self.locations = track
        self.name = name
        self.style = "default"
        self._id = Track.serial
        super.init()
        self.region = calcBounds(track: track)
    }
    
    init(_id :Int, name :String, trackDescription: String, track: [CLLocation]) {
        self.trackDescription = trackDescription
        self.date = Date()
        self.locations = track
        self.name = name
        self.style = "default"
        self._id = _id
        super.init()
        self.region = calcBounds(track: track)
    }
    
    init(points: [Location])
    {
        var location: CLLocation!
        var track :[CLLocation] = []
        for point in points {
            location = CLLocation(latitude: point.lat, longitude: point.long)
            track.append(location)
        }
        self.locations = track
        self.trackDescription = "Track description"
        self.date = Date()
        self.name = "Track name"
        self.style = "default"
        self._id = Track.serial
        super.init()
        self.region = calcBounds(track: track)
    }
    
    init(track: [CLLocation]) {
        self.trackDescription = "Track description"
        self.date = Date()
        self.locations = track
        self.name = "Track name"
        self.style = "default"
        self._id = Track.serial
        super.init()
        self.region = calcBounds(track: track)
    }
    
    init(track: [CLLocation], northMost :Double, southMost :Double, eastMost :Double, westMost :Double) {
        self.trackDescription = "Track description"
        self.date = Date()
        self.locations = track
        self.name = "Track name"
        self.style = "default"
        self._id = Track.serial
        super.init()
        self.region = calcBounds(track: track)
        self.north = northMost
        self.south = southMost
        self.east = eastMost
        self.west = westMost
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
    
    func getPolyline() -> MKPolyline {
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        return polyline
    }
}
