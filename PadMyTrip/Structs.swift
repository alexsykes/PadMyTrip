//
//  Structs.swift
//  PadMyTrip
//
//  Created by Alex on 26/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


struct MapData  {
    var name :String
    var mapDescription :String
    var date :Date
    var trackData :[TrackData]
//    var styles :[Style]
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case date
        case trackData
//        case styles
    }
}

extension MapData :Decodable  {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        mapDescription = try values.decode(String.self, forKey: .description)
        date = try values.decode(Date.self, forKey: .date)
        trackData = try values.decode([TrackData].self, forKey: .trackData)
//        styles = try values.decode([Style].self, forKey: .styles)
    }
}


extension MapData :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(mapDescription, forKey: .description)
        try container.encode(date, forKey: .date)
//        try container.encode(styles, forKey: .styles)
        try container.encode(trackData, forKey: .trackData)
    }
}

struct TrackData  {
    var name: String
//    var north :Double = 0.0
//    var south :Double = 0.0
//    var east :Double = 0.0
//    var west :Double = 0.0
    var points :[Location]
    
    enum CodingKeys: String, CodingKey {
        case points
//        case north
//        case south
//        case east
//        case west
        case name
    }
    
}

extension TrackData :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        points = try values.decode([Location].self, forKey: .points)
//        north = try values.decode(Double.self, forKey: .north)
//        south = try values.decode(Double.self, forKey: .south)
//        east = try values.decode(Double.self, forKey: .east)
//        west = try values.decode(Double.self, forKey: .west)
    }
}

extension TrackData :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(name, forKey: .name)
//        try container.encode(north, forKey: .north)
//        try container.encode(south, forKey: .south)
//        try container.encode(east, forKey: .east)
//        try container.encode(west, forKey: .west)
    }
}

struct Style  {
    var lineWidth :Double
    var strokeColour :Double
    
    enum CodingKeys: String, CodingKey {
        case lineWidth
        case strokeColour
    }
}

extension Style :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lineWidth = try values.decode(Double.self, forKey: .lineWidth)
        strokeColour = try values.decode(Double.self, forKey: .strokeColour)
    }
}

extension Style :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(strokeColour, forKey: .strokeColour)
    }
}

struct Location  {
    var long :Double
    var lat :Double
    var elevation :Double
    
    enum CodingKeys: String, CodingKey {
        case long
        case lat
        case elevation
    }
}
extension Location :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        long = try values.decode(Double.self, forKey: .long)
        lat = try values.decode(Double.self, forKey: .lat)
        elevation = try values.decode(Double.self, forKey: .elevation)
    }
}

extension Location :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
        try container.encode(elevation, forKey: .elevation)
    }
}
