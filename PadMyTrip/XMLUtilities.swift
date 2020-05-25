//
//  XMLUtilities.swift
//  PadMyTrip
//
//  Created by Alex on 22/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//
/// - Author: Alex Sykes
/// - Throws: an error - or something
/// - Returns: Something
/// - Parameters:
///  -
/// - Note: Explain what is going on [Reference] (https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html#//apple_ref/doc/uid/TP40016497-CH2-SW1))
/// - Important: DO not forget this…
/// - Version:


import UIKit
import CoreLocation

class XMLUtilities: NSObject, XMLParserDelegate {
    var parser: XMLParser!
    var xmlTrack: String!
    var csvString: String!
    
    var nextTrackID: Int!
    var defaults: UserDefaults!
    
    
    // GPX Import stuff
    var trackCount: Int!
    var pointCount: Int!
    var tracksRead: [[String]] = [[]]
    
    // Added for parsing
    var pointData:[String] = []
    var ele: String!
    var long: String!
    var lat: String!
    var date: String!
    var elementName: String!
    
    /// - Parameters: path: URL pathToXMLData
    /// - Returns: array of TrackData
    /// - Note: filename / segment number added
    func XML2CSV(path :URL) -> [TrackData] {
        if let parser = XMLParser(contentsOf: path) {
            parser.delegate = self
            parser.parse()
        }
        
        var trackName = path.lastPathComponent + ": Segment: "
        
        print("\(tracksRead.count)")
        var trackData: [TrackData] = []
        var points :[Location] = []
        var locations :[CLLocation] = []
        for track in tracksRead {
            if !track.isEmpty {
                for point in track {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[4])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    let loc = CLLocation(latitude: lat, longitude: long)
                    points.append(newLocation)
                    locations.append(loc)
                }
            }
            trackData.append(TrackData.init(name: "Segment", isVisible: true, _id: nextTrackID, points: points, style: 0))
        }
        return trackData
    }
    func XML2CSV() -> [TrackData] {
        if let path = Bundle.main.url(forResource: "Current", withExtension: "gpx") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        print("\(tracksRead.count)")
        var trackData: [TrackData] = []
        var points :[Location] = []
        var locations :[CLLocation] = []
        for track in tracksRead {
            if !track.isEmpty {
                for point in track {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[4])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    let loc = CLLocation(latitude: lat, longitude: long)
                    points.append(newLocation)
                    locations.append(loc)
                }
            }
            trackData.append(TrackData.init(name: "Segment", isVisible: true, _id: nextTrackID, points: points, style: 0))
        }
        return trackData
    }
    
    // XMLParser additions
    // MARK: parserDidStartDocument
    func parserDidStartDocument(_ parser: XMLParser) {
        //     print("parserDidStartDocument")
        pointData = []
        tracksRead.removeAll()
        trackCount = 0
        pointCount = 0
        print("XMLParser parserDidStartDocument")
    }
    
    // MARK: didStartElement
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qname: String?, attributes attributeDict: [String : String] = [:]) {
        
        //    print("didStartElement elementName: \(elementName) namespaceURI: \(String(describing: namespaceURI)) qualifiedName: \(String(describing: qname)) attributes: \(attributeDict)")
        
        if elementName == "trkpt" {
            lat = attributeDict["lat"]!
            long = attributeDict["lon"]!
            
        }
        else if elementName == "trkseg" {
            trackCount += 1
            pointCount = 0
            //     print("\(trackCount ?? 0) tracks")
        }
        
        self.elementName = elementName
    }
    
    // MARK: didEndElement
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //      print("didEndElement elementName: \(elementName) namespaceURI: \(String(describing: namespaceURI)) qualifiedName: \(String(describing: qName))")
        
        ///
        if elementName == "trkpt" {
            pointCount += 1
            print("\(pointCount ?? 0) points")
            
            //   pointData contains CSV String of lat, long, hacc, vacc, elev ,??, date
            let point: String = lat + "," + long + ",0,0," + ele + "," + date
            pointData.append(point)
        }
        else if elementName == "trkseg" {
            print("Track ended")
            // Track ended here
            tracksRead.append(pointData)
            pointData.removeAll()
        }
    }
    
    // MARK: foundCharacters
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("foundCharacters: \(string)")
        if (!data.isEmpty) {
            print("Data: \(data)")
            if self.elementName == "time" {
                date = data
            }
            if self.elementName == "ele" {
                ele = data
            }
        }
    }
    
    func parser(_ parser: XMLParser,
                didStartMappingPrefix prefix: String,
                toURI namespaceURI: String) {
        //    print("didStartMappingPrefix: \(prefix) namespaceURI: \(namespaceURI)")
    }
    
    // MARK: parserDidEndDocument
    /// What is going on here?
    /// - Parameter parser: parser reads data
    ///
    /// - Function
    func parserDidEndDocument(_ parser: XMLParser) {
        //    print("parserDidEndDocument")
        var trackData: [TrackData] = []
        
        /// At this stage, we have all tracks imported and held in tracksRead array
        
        var segment = 1
        defaults = UserDefaults.standard
        nextTrackID = defaults.integer(forKey: "nextTrackID")
        
        
        for trackRead in tracksRead {
            var points :[Location] = []
            var locations :[CLLocation] = []
            for point in trackRead {
                
                let location = point.split(separator: ",")
                let lat = Double(location[0])!
                let long = Double(location[1])!
                let elev = Double(location[4])!
                
                let newLocation = Location(long: long, lat: lat, elevation: elev)
                let loc = CLLocation(latitude: lat, longitude: long)
                points.append(newLocation)
                locations.append(loc)
            }
            let trackName = "Segment \(segment)"
            trackData.append(TrackData.init(name: trackName, isVisible: true, _id: nextTrackID, points: points, style: 0))
            segment += 1
            
            nextTrackID += 1
            defaults.set(nextTrackID, forKey: "nextTrackID")
        }
    }
}
