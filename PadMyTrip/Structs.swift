//
//  Structs.swift
//  PadMyTrip
//
//  Created by Alex on 26/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import Foundation
import CoreLocation


struct MapData :Codable {
    var name :String
    var description :String
    var trackData :[TrackData]
    var date :Date
    var northMost :Double
    var southMost :Double
    var westMost :Double
    var eastMost :Double
    var styles :[Style]
}


struct TrackData :Codable {
    var points :[Location]
}

struct Style :Codable {
    var lineWidth :Double
    var strokeColor :Double
    
}

struct Location :Codable {
    var long :Double
    var lat :Double
    var elevation :Double!
}
