//
//  Structs.swift
//  PadMyTrip
//
//  Created by Alex on 26/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import Foundation
import CoreLocation


struct MapData  {
    var name :String
    var mapDescription :String
    var date :Date
    var northMost :Double
    var southMost :Double
    var westMost :Double
    var eastMost :Double
    var trackData :[TrackData]
//    var styles :[Style]
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case date
        case northMost
        case eastMost
        case southMost
        case westMost
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
        northMost = try values.decode(Double.self , forKey: .northMost)
        southMost = try values.decode(Double.self , forKey: .southMost)
        eastMost = try values.decode(Double.self , forKey: .eastMost)
        westMost = try values.decode(Double.self , forKey: .westMost)
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
        try container.encode(northMost, forKey: .northMost)
        try container.encode(eastMost, forKey: .eastMost)
        try container.encode(westMost, forKey: .westMost)
        try container.encode(southMost, forKey: .southMost)
//        try container.encode(styles, forKey: .styles)
        try container.encode(trackData, forKey: .trackData)
    }
}

struct TrackData  {
    var name: String
    var points :[Location]
    
    enum CodingKeys: String, CodingKey {
        case points
    }
}

extension TrackData :Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        points = try values.decode([Location].self, forKey: .points)
        name = "Name"
    }
}

extension TrackData :Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
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
