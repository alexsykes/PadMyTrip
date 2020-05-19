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
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case date
        case trackData
        case trackIDs
//        case styles
    }
}

extension MapData :Decodable  {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        mapDescription = try values.decode(String.self, forKey: .description)
        date = try values.decode(Date.self, forKey: .date)
    }
}


extension MapData :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(mapDescription, forKey: .description)
        try container.encode(date, forKey: .date)
    }
}

struct TrackData  {
    var name: String
    var isVisible :Bool
    var _id: Int
    var points :[Location]
    var style :Int
    
    enum CodingKeys: String, CodingKey {
        case points
        case isVisible
        case _id
        case name
        case style
    }
    
}

extension TrackData :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        isVisible = try values.decode(Bool.self, forKey: .isVisible)
        points = try values.decode([Location].self, forKey: .points)
        _id = try values.decode(Int.self, forKey: ._id)
        style = try values.decode(Int.self, forKey: .style)
    }
}

extension TrackData :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(name, forKey: .name)
        try container.encode(_id, forKey: ._id)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encode(style, forKey: .style)
    }
}

struct Style  {
    var name :String
    var lineWidth :Double
    var strokeColour :Double
    var lineDashPattern: [Int]
    
    enum CodingKeys: String, CodingKey {
        case name
        case lineWidth
        case strokeColour
        case lineDashPattern
    }
}

extension Style :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        lineWidth = try values.decode(Double.self, forKey: .lineWidth)
        strokeColour = try values.decode(Double.self, forKey: .strokeColour)
        lineDashPattern = try values.decode([Int].self, forKey: .lineDashPattern)
    }
}

extension Style :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(strokeColour, forKey: .strokeColour)
        try container.encode(name, forKey: .name)
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
