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
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        return csv
    }
    
        // XMLParser additions
        // MARK: parserDidStartDocument
        func parserDidStartDocument(_ parser: XMLParser) {
            print("parserDidStartDocument")
        }
        
        // MARK: didStartElement
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qname: String?, attributes attributeDict: [String : String] = [:]) {

       print("parserDidStartElement elementName: \(elementName) namespaceURI: \(namespaceURI) qualifiedName: \(qname) attributes: \(attributeDict)")
        }
        
        // MARK: didEndElement
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        }
        
        // MARK: foundCharacters
        func parser(_ parser: XMLParser, foundCharacters string: String) {

        }
        
        func parser(_ parser: XMLParser,
                    didStartMappingPrefix prefix: String,
                    toURI namespaceURI: String) {
        }
        
        // MARK: parserDidEndDocument
        func parserDidEndDocument(_ parser: XMLParser) {
        }
}
