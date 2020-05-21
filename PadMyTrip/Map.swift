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
    var polylines :[MKPolyline] = []
    
    init(mapData :MapData) {
        self.name = mapData.name
        self.mapDescription = mapData.mapDescription
        self.date = mapData.date
    }
    
    init(name :String, mapDescription: String) {
        self.name = name
        self.mapDescription = mapDescription
        self.date = Date()
    }
    
    func addTrack(track :Track) {
        //   tracks.append(track)
    }
}
