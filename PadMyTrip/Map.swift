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
    //var tracks: [Track]! = []
    var mapDescription: String
    var date: Date
    var region: MKCoordinateRegion!
    var name: String
    var styles: [String]!
    var mapData :MapData!
    // var trackData :[TrackData]!
    // var trackIDs :[Int]!
    var polylines :[MKPolyline] = []
    
    init(mapData :MapData) {
        self.name = mapData.name
        self.mapDescription = mapData.mapDescription
        self.date = mapData.date
        //  self.trackData = []
        //  self.trackData = mapData.trackData
        //  self.trackData = []
        //  self.trackIDs = mapData.trackIDs
    }
    
    init(name :String, mapDescription: String) {
        self.name = name
        self.mapDescription = mapDescription
        self.date = Date()
        //  self.trackIDs = []
    }
    
    /*
     init(name :String, mapDescription: String, tracks: [Track]) {
     self.mapDescription = mapDescription
     self.date = Date()
     //  self.tracks = tracks
     self.name = name
     self.styles = ["default"]
     
     //    self.trackIDs = []
     super.init()
     //  calcBounds()
     }
     */
    
    /*    func calcBounds(){
     var northMost = -90.0
     var southMost = 90.0
     var eastMost = -180.0
     var westMost = 180.0
     
     
     for track in trackData {
     var locations:[CLLocation] = []
     let numPoints = track.points.count
     
     for index in 0..<numPoints {
     let curPoint = track.points[index]
     let lat = curPoint.lat
     let long = curPoint.long
     let location = CLLocation(latitude: lat, longitude: long)
     locations.append(location)
     
     if lat > northMost { northMost = lat }
     if lat < southMost { southMost = lat }
     if long > eastMost { eastMost = long }
     if long < westMost { westMost = long }
     }
     var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
     polylines.append(MKPolyline(coordinates: &coordinates, count: coordinates.count))
     
     }
     let centreLat = (northMost + southMost)/2
     let centreLong = (eastMost + westMost)/2
     let spanLong = 1.5 * (eastMost - westMost)
     let spanLat = 1.5 * (northMost - southMost)
     
     let centre = CLLocationCoordinate2D(latitude: centreLat, longitude: centreLong)
     let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
     region = MKCoordinateRegion(center: centre, span: span)
     
     }
     */
    
    func addTrack(track :Track) {
        //   tracks.append(track)
    }
}
