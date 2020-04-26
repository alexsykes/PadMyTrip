//
//  ViewController.swift
//  PadMyTrip
//
//  Created by Alex on 24/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIDocumentPickerDelegate {
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listBarButtonItem: UIBarButtonItem!
    
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    var trackFiles: [URL]!
    var tracks : [Track] = []
    var currentMap: Map!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set initial location in Honolulu
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        mapView.delegate = self
        getPermissions()
        setUpMap()
        currentMap = Map(name: "Untitled", mapDescription: "Some description")

    }
    
    
    // MARK: FunctionsDate()
    
    func encode () {
        var points :[Location] = []
        var trackData = [TrackData(points: points)]
        
        let map = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, trackData: trackData, date: Date(), northMost: currentMap.northMost, southMost: currentMap.southMost, westMost: currentMap.westMost, eastMost: currentMap.eastMost)
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(map) {
            if let json = String(data: encoded, encoding: .utf8) {
                print(json)
            }

            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(Language.self, from: encoded) {
                print(decoded.name)
            }
        }
    }
    func setUpMap() {
        mapView.mapType = .standard
        // mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        // mapView.showsCompass = true
    }
    

    // Update mapView using currentMap object
    func mapUpdate() {
         var polylines :[MKPolyline] = []
         for track in currentMap.tracks {
             let polyline = plotTrack(track: track)
             polylines.append(polyline)
         }
         let region = currentMap.calcBounds()
         mapView.setRegion(region, animated: true)
         mapView.addOverlays(polylines)
    }
    
    
    // Gets permisiions for location services
    func getPermissions() {
        // user activated automatic authorization info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: File Handling
    /* Presents user with a dialog box u
     user selects a file or files
     then the documentPicker didPickDocumentsAt event is fired
     */
    // TODO: Add/check Cancel button
    func readFromPublic () {
        
        // open a document picker, select a file
        // documentTypes see - https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        
        let importFileMenu = UIDocumentPickerViewController(documentTypes: ["public.text"],
                                                            in: UIDocumentPickerMode.import)
        
        importFileMenu.delegate = self
        importFileMenu.shouldShowFileExtensions = false
        importFileMenu.allowsMultipleSelection = true
        
        if #available(iOS 13.0, *) {
            // print("File iOS 13+")
            importFileMenu.directoryURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.alexsykes.MapMyTrip")!
        } else {
            // Fallback on earlier versions
            //  print("File iOS <=12")
        }
        importFileMenu.modalPresentationStyle = .automatic
        
        self.present(importFileMenu, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Final stage when writing file
    func writeOutputString (dataString: String, fileName: String, fileExtension: String) {
        let longFileName = fileName + fileExtension
        
        let url = self.getDocumentsDirectory().appendingPathComponent(longFileName)
        
        do {
            try dataString.write(to: url, atomically: true, encoding: .utf8)
            // let input = try String(contentsOf: url)
            //  print(input)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Read date from file(s) returned by documentPicker
    // Need to add CSV filter - done
    func readReturnedTracks() {
        
        
        // Set up polylines to be returned
       //var polylines :[MKPolyline] = []
        // filter files for correct extension
        let csvURLs = trackFiles.filter{ $0.pathExtension == "csv"}
        
        // For each file convert array of CLLocations
        // into a single polyline
        for file in csvURLs {
            let trackData = readFile(url :file)     // trackData -> array of Strings : each line becomes one location in
            let locations :[CLLocation] = prepareLocations(trackData: trackData) // trackLocations -> array of CLLocation to be converted to
            
            let newTrack = Track(name: "Unnamed track", trackDescription: "Description goes here", track: locations)
            tracks.append(newTrack)
            currentMap.addTrack(track: newTrack)
            
         //   let polyline = convertToPolyline(trackLocations: locations)
            // let count = polyline.pointCount
            //  print("\(count)")
         //   polylines.append(polyline)
        }
        
        mapUpdate()
        
//        let region = tracks.last!.region!
//        let region = currentMap.calcBounds(tracks: tracks)
//
//        mapView.setRegion(region, animated: true)
//        showTracksOnMap(polylines: polylines)
    }
    
    func showTracksOnMap(polylines: [MKPolyline]) {
        mapView.addOverlays(polylines)
    }
    
    // Render track on currentMap
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    // MARK: Start here
    //    // Plots track loaded from visitedLocations array
    //    func plotCurrentTrack() {
    //        // if (visitedLocations.last as CLLocation?) != nil {
    //        var coordinates = track.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
    //        polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    //        mapView.addOverlay(polyline)
    //        //  }
    //    }
    
    func convertToPolyline(trackLocations :[CLLocation]) -> MKPolyline {
        
        var coordinates = trackLocations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        return polyline
    }
    
    func prepareLocations(trackData: [String]) -> [CLLocation] {
        var locations :[CLLocation] = []
        var theLocation: CLLocation!
        var elevation: Double!
        var latitude: Double!
        var longitude: Double!
        var hacc: Double!
        var vacc: Double!
        var timestampS: String!
        var coordinate: CLLocationCoordinate2D
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var values :[String] = []
        
        for point in trackData {
            values  = point.components(separatedBy: ",")
            latitude = Double(values[0])
            longitude = Double(values[1])
            hacc = Double(values[2])
            vacc = Double(values[3])
            elevation = Double(values[4])
            timestampS = values[5]
            
            let date = formatter.date(from: timestampS)
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            theLocation = CLLocation(coordinate: coordinate, altitude: elevation, horizontalAccuracy: hacc, verticalAccuracy: vacc, timestamp: date ?? Date())
            locations.append(theLocation)
        }
        return locations
    }
    
    // Read trackdata from storage
    // Return array of Strings
    func readFile(url :URL) -> [String] {
        var points:[String] = []
        let path = url.path
        let fileContents = FileManager.default.contents(atPath: path)
        let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
        
        // Split lines then append to array
        let lines = fileContentsAsString!.split(separator: "\n")
        for line in lines {
            points.append(String(line))
        }
        return points
    }
    
    func plotTrack(track :Track) -> MKPolyline {
        let locations = track.locations!
        let polyline = convertToPolyline(trackLocations: locations)
        return polyline
    }
    
    // MARK: Actions
    @IBAction func fileButtonClicked(_ sender: UIBarButtonItem) {
        readFromPublic()
    }
    
    @IBAction func printJSON(_ sender: UIBarButtonItem) {
        encode()
    }
    
    @IBAction func mapUpdate(_ sender: Any) {
        if currentMap.tracks.count > 0 {
        mapUpdate()
        }
    }
    
    // MARK: Delegated methods
    // Mark: Change of location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _ = locations.last! as CLLocation
        locationManager.stopUpdatingLocation()
    }
    
    // Documents picked
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        trackFiles = urls
        // Add check for zero return
        readReturnedTracks()
    }
    
    struct Language: Codable {
        var name: String
        var version: Int
    }

}
