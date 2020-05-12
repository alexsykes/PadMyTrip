//
//  MainViewController.swift
//  PadMyTrip
//
//  Created by Alex on 05/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, MKMapViewDelegate, SettingsDelegate, TrackDetailDelegate   {
    
    
    func trackDetailUpdated(trackDetails: [String : String], isTrackIncluded: Bool) {
        let trackID = Int(trackDetails["trackID"]!)
        _  = trackDetails["trackName"]
        let index = 0
        for _ in 0..<currentMap.trackData.count{
            print("\(currentMap.trackData[index].name)")
        }
        if isTrackIncluded {
        currentMap.trackIDs.append(trackID!)
        } else { currentMap.trackIDs = currentMap.trackIDs.filter{ $0 != trackID } }
    }
    
    
    
    // MARK: Properties
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackTableView: UITableView!
    
    // MARK: Variables
    var files :[URL]! = []
    var currentMap :Map!            // Map class - used to hold data displayed on MKMapView
    var map :MapData!               // Struct representing a Map used for storing data in Codable format
    var overlays :[MKOverlay]!
    var defaults :UserDefaults!
    var nextTrackID: Int!
    var trackIDs :[Int]!
    var trackData :[TrackData]!
    
    
    // MARK: Actions
    // + Button clicked
    @IBAction func addFromPublic(_ sender: UIBarButtonItem) {
        presentFilePicker()
    }
    
    // MARK: Start here - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults = UserDefaults.standard
        nextTrackID = defaults.integer(forKey: "nextTrackID")
        
        // Setup delegation
        mapView.delegate = self
        trackTableView.dataSource = self
        trackTableView.delegate = self
        trackTableView.allowsMultipleSelection = true
        
        // Setup currentMap and populate from data in JSON data
        loadSavedMapData()
        loadSavedTrackData()
        
        currentMap = Map(mapData: map)
        // At this point, all tracks are loaded from storage.
        
        self.title = currentMap.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.title = currentMap.name
        
        // Recalc
        mapRefresh()
        print("ViewWillAppear fired")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveFileData()
    }
    
    // MARK: Load saved map data
    func loadSavedMapData () {
        // Read saved map data into Mapdata struct
        map = MapData(name: "Map name", mapDescription: "A description of my map", date: Date(),  trackIDs: [])
        readStoredJSONMapData()
        // map.trackData.sort(by: {$0.name.lowercased() < $1.name.lowercased()} )
        
    }
    
    func loadSavedTrackData () {
        readStoredJSONTrackData()
        
    }
    
    // MARK: Write file data
    func saveFileData() {
        // Encode data then write to disk
        let data :Data = encodeTrackData()
        writeData(data: data, filename: "Tracks.txt")
        let mapData :Data = encodeMapData()
        writeData(data: mapData, filename: "MapAlt.txt")
    }
    
    // MARK: File Handling - Import tracks from Public data
    // TODO: Add/check Cancel button
    func presentFilePicker () {
        
        // open a document picker, select a file
        // documentTypes see - https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        
        let importFileMenu = UIDocumentPickerViewController(documentTypes: ["public.plain-text"],
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
    
    
    // MARK: Tracks read from documents
    func processImportedTracks(trackURLs :[URL])  {
        let fileManager = FileManager.init()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // Check that only CSV files are processed
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
                var locations :[CLLocation] = []
                for point in pointData {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[2])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    let loc = CLLocation(latitude: lat, longitude: long)
                    points.append(newLocation)
                    locations.append(loc)
                }
                trackData.append(TrackData.init(name: filename, _id: nextTrackID, points: points))
                currentMap.trackIDs.append(nextTrackID)
                nextTrackID += 1
                defaults.set(nextTrackID, forKey: "nextTrackID")
                try
                    fileManager.removeItem(at: newFileURL)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
        mapRefresh()
    }
    
    func mapRefresh() {
        // let trackData = currentMap.trackData
        
        // Remove current clutter
        currentMap.polylines = []
        var hasValidTracks = false // Boolean flag to avoid map out of bounds errors
        var overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        overlays.removeAll()
        
        // Check that there are trackData added
        if currentMap.trackData.count == 0 {
            return
        }
        
        // Create a polyline for each track
        for trackData in trackData {
            var locs :[CLLocationCoordinate2D] = []
            // Check for empty trackData
            if trackData.points.count > 0 {
                hasValidTracks = true
                for point in trackData.points {
                    let location = CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
                    locs.append(location)
                }
            }
            let polyline = MKPolyline(coordinates: locs, count: locs.count)
            currentMap.polylines.append(polyline)
        }
        if hasValidTracks == true {
            for polyline in currentMap.polylines {
                overlays.append(polyline)
            }
            mapView.addOverlays(overlays)
            
            // Calculate map region then apply
            currentMap.calcBounds()
            mapView.region = currentMap.region
        }
        else { return }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func calcBounds(trackData :[CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var northMost = -90.0
        var southMost = 90.0
        var eastMost = -180.0
        var westMost = 180.0
        
        for curPoint in trackData {
            let lat = curPoint.latitude
            let long = curPoint.longitude
            
            if lat > northMost { northMost = lat }
            if lat < southMost { southMost = lat }
            if long > eastMost { eastMost = long }
            if long < westMost { westMost = long }
        }
        
        
        let centreLat = (northMost + southMost)/2
        let centreLong = (eastMost + westMost)/2
        let spanLong = 1.5 * (eastMost - westMost)
        let spanLat = 1.5 * (northMost - southMost)
        
        let centre = CLLocationCoordinate2D(latitude: centreLat, longitude: centreLong)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
        return MKCoordinateRegion(center: centre, span: span)
        
    }
    
    
    // MARK: Data decoding
    func readStoredJSONTrackData() {
        let url = self.getDocumentsDirectory().appendingPathComponent("Tracks.txt")
        
        let fileManager = FileManager.default
        
        // Check if file exists, given its path
        let path = url.path
        
        if(!fileManager.fileExists(atPath:path)){
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        }else{
            print("Track file exists")
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
            trackData  = try decoder.decode([TrackData].self, from: jsonData)
            // print(map!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: Data encoding
    func readStoredJSONMapData() {
        let url = self.getDocumentsDirectory().appendingPathComponent("MapAlt.txt")
        
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
    // MARK: Important - check to nextTrackID
    func encodeTrackData () -> Data {
        var encodedData :Data!
        // Structs - MapData, Location, TrackData
        // var points :[Location] = []
        var tData :[TrackData] = []
        
        // Work through data track by track :: point by point
        // Each track comprises a set of points
        for track in trackData {
            
            // For each track, add each location to the points array
            let name = track.name
            let _id = track._id
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
            tData.append(TrackData.init(name: name, _id: _id, points: points))
        }
        
        // let mapData = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, date: Date(), trackIDs: currentMap.trackIDs, trackData: tData)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tData) {
            encodedData = encoded
        }
        return encodedData
    }
    
    // MARK: Map data
    func encodeMapData () -> Data {
        var encodedData :Data!
        let mapData = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, date: Date(), trackIDs: currentMap.trackIDs)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mapData) {
            encodedData = encoded
        }
        return encodedData
    }
    
    func writeData(data :Data, filename :String) {
        let url = self.getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            //      try data.write(to: alt)
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
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: MapView functions
    
    // Display tracks on MapView
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
        mapView.addOverlays(currentMap.polylines)
        // mapView.setRegion(region, animated: true)
        
    }
    
    // Plots track loaded from visitedLocations array
    func plotCurrentTrack() {
        // if (visitedLocations.last as CLLocation?) != nil {
        //   var coordinates = visitedLocations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        //   let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        //   mapView.addOverlay(polyline)
        //  }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        let identifier = segue.identifier
        if identifier == "displayTrack" {
            
            guard let trackViewController = segue.destination as? TrackViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? TrackViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = self.trackTableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let row = indexPath.row
            let track = trackData[row]
            let activeTracks = currentMap.trackIDs
            let id = track._id
            
            trackViewController.trackData = track
            trackViewController.delegate = self
            trackViewController.isTrackIncluded = activeTracks?.contains(id)
            
        } else {
            if identifier == "showPrefs" {
                
                guard let settingsViewController = segue.destination as? SettingsViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                settingsViewController.mapName = currentMap.name
                settingsViewController.mapDescription = currentMap.mapDescription
                settingsViewController.delegate = self
            }
        }
    }
    
    // MARK: Delegated functions
    
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
        let pointsCount =  trackData[indexPath.row].points.count
        let _id = trackData[indexPath.row]._id
        cell.titleLabel?.text = "\(trackName)"
        cell.pointsCount.text = "Track id: \(_id) has \(pointsCount) points"
        cell.accessoryType = .checkmark
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
            print ("Row: \(indexPath.row)")
            trackData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveFileData()
            mapRefresh()
        } else if editingStyle == .insert {
            // Insert here
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
        print("mapViewDidFinishLoadingMap")
        // plotCurrentTrack()
    }
    
    // Render track on map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        // renderer.lineDashPattern = .some([4, 16, 16])
        return renderer
    }
    
    /*
     func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
     let row = indexPath.row
     print ("Button tapped: \(row)")
     }
     */
    
    // MARK: Delegated functions
    // Return from TrackViewController
    
    
    // Passback from SettingsViewController
    func userDidEnterInformation(mapDetails: [String]) {
        currentMap.name = mapDetails[0]
        currentMap.mapDescription = mapDetails[1]
        map.name = mapDetails[0]
        map.mapDescription = mapDetails[1]
    }
    
}

