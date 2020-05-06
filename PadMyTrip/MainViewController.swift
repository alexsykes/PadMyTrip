//
//  MainViewController.swift
//  PadMyTrip
//
//  Created by Alex on 05/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, MKMapViewDelegate   {
    
    // MARK: Properties
    // From TrackTableViewController
    var files :[URL]! = []
    var tracks :[Track] = []
    //  var mapViewController = MapViewController(nibName: "mapViewController", bundle: nil)
    var mapView :MKMapView!         // MKMapView item
    var currentMap :Map!            // Map class - is this used?
    var map :MapData!               // Struct representing a Map
    var trackData: [TrackData]!
    var polylines :[MKPolyline] = []
    var trackIndex: Int!
    
    var trackTableView: UITableView!
    
    @IBAction func addFromPublic(_ sender: UIBarButtonItem) {
        addTracksFromPublic()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegation
        mapView.delegate = self
        trackTableView.dataSource = self
        trackTableView.delegate = self
        trackTableView.allowsMultipleSelection = true
        
        currentMap = Map(name: "Line 38", mapDescription: "Line 38 description")
        currentMap.tracks = []
        
        // Read saved map data
        map = MapData(name: "Map name", mapDescription: "A description of my map", date: Date(), northMost: -90, southMost: 90, westMost: -180, eastMost: 180, trackData: [])
        readStoredJSONData()
        trackData = map.trackData
        trackData.sort(by: {$0.name.lowercased() < $1.name.lowercased()} )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveFileData()
    }
    
    
    
    // MARK: Write file data
    func saveFileData() {
        // Encode data then write to disk
        let data :Data = encode()
        writeData(data: data)
    }
    
    // MARK: File Handling
    // TODO: Add/check Cancel button
    func addTracksFromPublic () {
        
        // open a document picker, select a file
        // documentTypes see - https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        
        let importFileMenu = UIDocumentPickerViewController(documentTypes: ["public.text"],
                                                            in: UIDocumentPickerMode.import)
        
        importFileMenu.delegate = self
        importFileMenu.shouldShowFileExtensions = true
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
    
    
    // Documents picked
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        // var trackFiles = urls
        // Add check for zero return
        
        if urls.count == 0 { return}
        processImportedTracks(trackURLs: urls)
        
        saveFileData()
        // readStoredData()
        DispatchQueue.main.async { self.trackTableView.reloadData() }
    }
    
    func processImportedTracks(trackURLs :[URL])  {
        let fileManager = FileManager.init()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let csvURLs = trackURLs.filter{ $0.pathExtension == "csv"}
        for trackURL in csvURLs {
            let filename = trackURL.lastPathComponent
            let newFileURL = docDir.appendingPathComponent(filename)
            do {
                try
                    fileManager.copyItem(at: trackURL, to: newFileURL)
                // Convert to JSON
                var pointData:[String] = []
                let path = newFileURL.path
                let fileContents = FileManager.default.contents(atPath: path)
                let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
                
                // Split lines then append to array
                let lines = fileContentsAsString!.split(separator: "\n")
                for line in lines {
                    pointData.append(String(line))
                }
                
                print("Points: \(pointData.count)")
                var points :[Location] = []
                for point in pointData {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[2])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    points.append(newLocation)
                }
                trackData.append(TrackData.init(name:filename,points: points))
                try
                    fileManager.removeItem(at: newFileURL)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
    }
    
    func importAndConvertToJSON(trackURL :URL, newFileURL :URL) throws {
        let fileManager = FileManager.init()
        do {
            try
                fileManager.copyItem(at: trackURL, to: newFileURL)
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: Read locally stored files
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
    
    // MARK: Data encoding
    func readStoredJSONData() {
        let url = self.getDocumentsDirectory().appendingPathComponent("MyMap.dat")
        
        let fileManager = FileManager.default
        
        // Check if file exists, given its path
        let path = url.path
        
        if(!fileManager.fileExists(atPath:path)){
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }else{
            print("Map file exists")
        }
        
        var jsonData :Data!
        do {
            jsonData = try Data(contentsOf: url)
            
            if jsonData.count == 0 {
                print("Map file contains no data")
                return
            }
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            map = try decoder.decode(MapData.self, from: jsonData)
            // print(map!)
        } catch {
            print(error.localizedDescription)
        }
    }
    //
    //       func encodeOld () -> Data {
    //           var encodedData :Data!
    //           // Structs - MapData, Location, TrackData
    //           // var points :[Location] = []
    //           var dataToSave :[TrackData] = []
    //
    //           // Work through data track by track :: point by point
    //           // Each track comprises a set of points
    //           for track in trackData {
    //
    //               // For each track, add each location to the points array
    //
    //               // Firstly, start with an empty array
    //               var points :[Location] = []
    //               for point in track.points {
    //
    //                   // Add the data for each point
    //                   let lat = point.lat
    //                   let long = point.long
    //                   let elevation = point.elevation
    //
    //                   let point = Location.init(long: long, lat: lat, elevation: elevation)
    //                   // then append to the array
    //                   points.append(point)
    //               }
    //               // Once the tack points array is populated,
    //               // append the array of points to the trackData
    //
    //               dataToSave.removeAll()
    //               dataToSave.append(TrackData.init(name:"Track name",points: points))
    //               // encodedData = Data(dataToSave.utf8)
    //               //return encodedData
    //           }
    //
    //           let mapData = MapData(name: map.name, mapDescription: map.mapDescription, date: Date(), northMost: map.northMost, southMost: map.southMost, westMost: map.westMost, eastMost: map.eastMost, trackData: trackData)
    //
    //
    //           let encoder = JSONEncoder()
    //           if let encoded = try? encoder.encode(mapData) {
    //               if let json = String(data: encoded, encoding: .utf8) {
    //                   print(json)
    //               }
    //               encodedData = encoded
    //
    //               let decoder = JSONDecoder()
    //               if let decoded = try? decoder.decode(MapData.self, from: encoded) {
    //                   print(decoded)
    //               }
    //           }
    //           return encodedData
    //       }
    
    func encode () -> Data {
        var encodedData :Data!
        // Structs - MapData, Location, TrackData
        // var points :[Location] = []
        var tData :[TrackData] = []
        
        // Work through data track by track :: point by point
        // Each track comprises a set of points
        for track in trackData {
            
            // For each track, add each location to the points array
            let name = track.name
            // Firstly, start with an empty array
            var points :[Location] = []
            for location in track.points {
                
                // Add the data for each point
                let lat = location.lat
                let long = location.long
                let elevation = location.elevation
                
                let point = Location.init(long: long, lat: lat, elevation: elevation)
                // then append to the array
                points.append(point)
            }
            // Once the tack points array is populated,
            // append the array of points to the trackData
            tData.append(TrackData.init(name: name, points: points))
        }
        
        let mapData = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, date: Date(), northMost: currentMap.northMost, southMost: currentMap.southMost, westMost: currentMap.westMost, eastMost: currentMap.eastMost, trackData: tData)
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mapData) {
            //               if let json = String(data: encoded, encoding: .utf8) {
            //                   // print(json)
            //               }
            encodedData = encoded
            
            // let decoder = JSONDecoder()
            //               if let decoded = try? decoder.decode(MapData.self, from: encoded) {
            //                   // print(decoded)
            //               }
            
            
        }
        return encodedData
    }
    
    func writeData(data :Data) {
        let longFileName = "MyMap.dat"
        let url = self.getDocumentsDirectory().appendingPathComponent(longFileName)
        
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
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
    
    // MARK: Map functions
    
    func displayTrack(track trackId: Int) {
        let theTrack = trackData[trackId]
        var locations : [CLLocation] = []
        let name = theTrack.name
        let description = "A track"
        let points = theTrack.points
        for point in points {
            let lat = point.lat
            let long = point.long
            let location = CLLocation(latitude: lat, longitude: long)
            locations.append(location)
        }
        
        let track :Track = Track(name: name, trackDescription: description, track: locations)
        
        self.currentMap.addTrack(track: track)
        let region = self.currentMap.calcBounds()
        
        mapView.addOverlays(polylines)
        mapView.setRegion(region, animated: true)
        
    }
    
    // Plots track loaded from visitedLocations array
    func plotCurrentTrack() {
        // if (visitedLocations.last as CLLocation?) != nil {
        //   var coordinates = visitedLocations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        //   let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        //   mapView.addOverlay(polyline)
        //  }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  trackData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackTableCell", for: indexPath) as! TrackViewCell
        let trackName = trackData[indexPath.row].name
        cell.titleLabel?.text = "\(trackName)"
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            trackData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveFileData()
        } else if editingStyle == .insert {
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        displayTrack(track: row)
        print("Clicked: \(row) ")
    }
    
    // MARK:  Events
    // Plot currently active track when map loads
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        plotCurrentTrack()
    }
}
