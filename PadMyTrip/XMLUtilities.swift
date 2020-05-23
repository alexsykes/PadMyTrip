//
//  XMLUtilities.swift
//  PadMyTrip
//
//  Created by Alex on 22/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit

class XMLUtilities: NSObject, XMLParserDelegate {
    var parser: XMLParser!
    var xmlTrack: String!
    var csvString: String!
    
    
    override init() {
        super.init()
    }
    
    func XML2CSV() -> String {
        var csv = ""
        if let path = Bundle.main.url(forResource: "Track", withExtension: "gpx") {
            if let parser = XMLParser() {
                parser.delegate = self
                parser.parse()
            }
        }
        return csv
    }
}
