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
import Foundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, MKMapViewDelegate, SettingsDelegate, TrackDetailDelegate, NewTableViewCellDelegate, XMLParserDelegate {
    
    
    
    // MARK: Properties
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackTableView: UITableView!
    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var eyeImage: UIImageView!
    
    // MARK: Variables
    var files :[URL]! = []       // Garmin track imports
    var currentMap :Map!            // Map class - used to hold data displayed on MKMapView
    var map :MapData!               // Struct representing a Map used for storing data in Codable format
    var overlays :[MKOverlay]!
    var defaults :UserDefaults!
    var nextTrackID: Int!
    var trackIDs :[Int]!
    var trackData :[TrackData]!
    var gPXTracks: [GPXTrack]!
    let mapFileName = "Map.txt"
    let trackFileName = "Tracks.txt"
    var polylines :[MKPolyline] = []
    var region: MKCoordinateRegion!
    
    // Added for parsing
    var pointData:[String] = []
    var ele: String!
    var long: String!
    var lat: String!
    var date: String!
    var elementName: String!
    
    // MARK: Actions
    // + Button clicked
    @IBAction func addFromPublic(_ sender: UIBarButtonItem) {
        presentFilePicker()
    }
    
    @IBAction func toggleVisibility(_ sender: UIButton) {
        print("Toggle button clicked")
    }
    // MARK: Start here - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
        defaults = UserDefaults.standard
        nextTrackID = defaults.integer(forKey: "nextTrackID")
        
        // Setup delegation
        mapView.delegate = self
        trackTableView.dataSource = self
        trackTableView.delegate = self
        trackTableView.allowsMultipleSelection = true
        
        // Setup currentMap and populate from data in JSON data
        trackData = []
        loadSavedMapData()
        loadSavedTrackData()
        
        currentMap = Map(mapData: map)
        
        self.title = currentMap.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.title = currentMap.name
        
        trackTableView.reloadData()
        // Recalc
        mapRefresh()
        print("ViewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveFileData()
    }
    
    // MARK: Load saved map data
    func loadSavedMapData () {
        // Read saved map data into Mapdata struct
        map = MapData(name: "Map name", mapDescription: "A description of my map", date: Date())
        readStoredJSONMapData()
    }
    
    func loadSavedTrackData () {
        readStoredJSONTrackData()
        
    }
    
    // MARK: Write file data
    func saveFileData() {
        // Encode data then write to disk
        let data :Data = encodeTrackData()
        writeData(data: data, filename: trackFileName)
        let mapData :Data = encodeMapData()
        writeData(data: mapData, filename: mapFileName)
    }
    
    // MARK: File Handling - Import tracks from Public data
    // TODO: Add/check Cancel button
    func presentFilePicker () {
        
        // open a document picker, select a file
        // documentTypes see - https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        
        let importFileMenu = UIDocumentPickerViewController(documentTypes: ["public.content", "public.data"],
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
        // Check that only CSV files are processed
        let importFileURLs = trackURLs.filter{ $0.pathExtension == "csv" || $0.pathExtension == "gpx" /* || $0.pathExtension == "kml"*/ }
        
        
        for trackURL in importFileURLs {
            let filename = trackURL.lastPathComponent
            let path = trackURL.path
            
            // Start again
            pointData.removeAll()
            
            // Check for filetype
            // Start CSV file
            if trackURL.pathExtension == "csv" {
                // Convert to JSON
                let fileContents = FileManager.default.contents(atPath: path)
                let fileContentsAsString = String(bytes: fileContents!, encoding: .utf8)
                
                // Split lines then append to array
                let lines = fileContentsAsString!.split(separator: "\n")
                for line in lines {
                    pointData.append(String(line))
                }
                // End CSV file
            }  else if trackURL.pathExtension == "gpx" {
                // Start GPX file
                
                if let parser = XMLParser(contentsOf: trackURL) {
                    parser.delegate = self
                    parser.parse()
                }
            }
                print("GPX file")
                print("Points: \(pointData.count)")
                var points :[Location] = []
                var locations :[CLLocation] = []
                for point in pointData {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[4])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    let loc = CLLocation(latitude: lat, longitude: long)
                    points.append(newLocation)
                    locations.append(loc)
                }
                trackData.append(TrackData.init(name: filename, isVisible: true, _id: nextTrackID, points: points, style: 0))
                // currentMap.trackIDs.append(nextTrackID)
                nextTrackID += 1
                defaults.set(nextTrackID, forKey: "nextTrackID")
                
                mapRefresh()
                return
            }
        
    }
    
    func importCSVTracks() -> [CLLocation]{
        let locations :[CLLocation] = []
        
        return locations
    }
    
    func importGPXTracks() -> [CLLocation]{
        let locations :[CLLocation] = []
           
           return locations
       }
    
    func importKMLTracks()  -> [CLLocation]{
        let locations :[CLLocation] = []
           
           return locations
       }
    
    func mapRefresh() {
        // Remove current clutter
        currentMap.polylines = []
        var hasValidTracks = false // Boolean flag to avoid map out of bounds errors
        var overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        overlays.removeAll()
        
        // Check that there are trackData added
        if trackData.count == 0 {
            return
        }
        
        // Create a polyline for each track
        for trackData in trackData {
            var locs :[CLLocationCoordinate2D] = []
            // Check for empty trackData
            if trackData.points.count > 0 && trackData.isVisible{
                hasValidTracks = true
                for point in trackData.points {
                    let location = CLLocationCoordinate2D(latitude: point.lat, longitude: point.long)
                    locs.append(location)
                }
            }
            
            if trackData.style == 0 {
                currentMap.polylines.append(RoadOverlay(coordinates: locs, count: locs.count))
            } else if trackData.style == 1{
                currentMap.polylines.append(TrackOverlay(coordinates: locs, count: locs.count))
            }  else if trackData.style == 2{
                currentMap.polylines.append(PathOverlay(coordinates: locs, count: locs.count))
            }  else if trackData.style == 3{
                currentMap.polylines.append(SmallPathOverlay(coordinates: locs, count: locs.count))
            }
        }
        if hasValidTracks == true {
            for polyline in currentMap.polylines {
                overlays.append(polyline)
            }
            mapView.addOverlays(overlays)
            
            // Calculate map region then apply
            calcBounds()
            mapView.region = region
        }
        else { return }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    // MARK: Data decoding
    // Reads all saved trackData from storage
    func readStoredJSONTrackData() {
        let url = self.getDocumentsDirectory().appendingPathComponent(trackFileName)
        
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
            
            if jsonData.isEmpty{
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
        let url = self.getDocumentsDirectory().appendingPathComponent(mapFileName)
        
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
    
    // MARK: Encoding data for writing
    func encodeTrackData () -> Data {
        var encodedData :Data!
        // Structs - MapData, Location, TrackData
        var tData :[TrackData] = []
        
        // Work through data track by track :: point by point
        // Each track comprises a set of points
        for track in trackData {
            
            // For each track, add each location to the points array
            let name = track.name
            let _id = track._id
            let style = track.style
            let isVisible :Bool = track.isVisible
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
            tData.append(TrackData.init(name: name, isVisible: isVisible, _id: _id, points: points, style: style))
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tData) {
            encodedData = encoded
        }
        return encodedData
    }
    
    func encodeMapData () -> Data {
        var encodedData :Data!
        let mapData = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, date: Date())
        
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
    
    
    
    func calcBounds(){
        var northMost = -90.0
        var southMost = 90.0
        var eastMost = -180.0
        var westMost = 180.0
        
        
        for track in trackData {
            var locations:[CLLocation] = []
            let numPoints = track.points.count
            
            for index in 0..<numPoints {
                let curPoint = track.points[index]
                let lat = curPoint.lat
                let long = curPoint.long
                let location = CLLocation(latitude: lat, longitude: long)
                locations.append(location)
                
                if lat > northMost { northMost = lat }
                if lat < southMost { southMost = lat }
                if long > eastMost { eastMost = long }
                if long < westMost { westMost = long }
            }
        }
        let centreLat = (northMost + southMost)/2
        let centreLong = (eastMost + westMost)/2
        let spanLong = 1.5 * (eastMost - westMost)
        let spanLat = 1.5 * (northMost - southMost)
        
        let centre = CLLocationCoordinate2D(latitude: centreLat, longitude: centreLong)
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
        region = MKCoordinateRegion(center: centre, span: span)
        
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let identifier = segue.identifier
        if identifier == "displayTrack" {
            
            guard let trackViewController = segue.destination as? TrackViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? NewTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = self.trackTableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let row = indexPath.row
            let track = trackData[row]
            
            trackViewController.trackData = track
            trackViewController.delegate = self
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "newTableViewCell", for: indexPath) as! NewTableViewCell
        let row = trackData[indexPath.row]
        let trackName = row.name
        let pointsCount =  row.points.count
        let _id = trackData[indexPath.row]._id
        cell.delegate = self
        
        if row.isVisible == true {
            cell.button.setImage(UIImage.init(systemName: "eye.fill"), for: .normal)
        } else {
            cell.button.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        }
        
        cell.nameLabel?.text = "\(trackName)"
        cell.pointsCount.text = "Track id: \(_id) has \(pointsCount) points"
        // cell.accessoryType = .checkmark
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    
    // MARK: Check if track is included in current map
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
    
    /*
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     tableView.deselectRow(at: indexPath, animated: true)
     let row = indexPath.row
     displayTrack(track: row)
     }*/
    
    // MARK:  Events
    // Plot currently active track when map loads
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
    }
    
    // MARK: Rendering
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        if overlay is RoadOverlay {
            renderer.strokeColor = UIColor.black
            renderer.alpha = 1
            renderer.lineWidth = 3
            //  renderer.lineDashPattern = [4,16,4,8]
            
        } else if overlay is TrackOverlay {
            renderer.strokeColor = .black
            renderer.lineWidth = 2
            // renderer.lineDashPattern = [16,8,8,8]
            //  renderer.lineDashPhase = 12
            
        } else if overlay is PathOverlay {
            renderer.strokeColor = .brown
            renderer.lineWidth = 2
            renderer.lineDashPattern = [16,8]
            renderer.lineDashPhase = 8
            
        } else if overlay is SmallPathOverlay {
            renderer.strokeColor = .brown
            renderer.lineWidth = 2
            renderer.lineDashPattern = [8,8]
            renderer.lineDashPhase = 4
            
        } else {
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 5
        }
        return renderer
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let row = indexPath.row
        print ("Button tapped: \(row)")
    }
    
    
    // MARK: Delegated functions
    // Return from TrackViewController
    
    
    // Passback from SettingsViewController
    func userDidEnterInformation(mapDetails: [String]) {
        currentMap.name = mapDetails[0]
        currentMap.mapDescription = mapDetails[1]
        map.name = mapDetails[0]
        map.mapDescription = mapDetails[1]
        
    }
    // MARK: NewTableViewCellDelegate
    
    func buttonTapped(cell: NewTableViewCell) {
        guard let indexPath = self.trackTableView.indexPath(for: cell) else {
            return
        }
        
        let row = indexPath.row
        let isVisible = trackData[row].isVisible
        if isVisible {
            trackData[row].isVisible = false
            cell.button.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        } else {
            trackData[row].isVisible = true
            cell.button.setImage(UIImage.init(systemName: "eye.fill"), for: .normal)
        }
        trackTableView.reloadData()
        mapRefresh()
    }
    
    
    func trackDetailUpdated(trackDetails: [String : String], isTrackIncluded: Bool) {
        // Not sure if this is still necessary / helpful
        print ("MainViewController.trackDetailsUpdated")
        let trackID = Int(trackDetails["trackID"]!)
        let newName  = trackDetails["trackName"]
        
        let tracks :[TrackData] = self.trackData.filter{$0._id == trackID}
        self.trackData = self.trackData.filter{$0._id != trackID}
        var track = tracks[0]
        track.name = newName!
        track.isVisible = isTrackIncluded
        track.style = Int(trackDetails["lineStyle"]!)!
        self.trackData.append(track)
        saveFileData()
        trackTableView.reloadData()
    }
    
    
    class RoadOverlay: MKPolyline{
    }
    class TrackOverlay: MKPolyline{
    }
    class PathOverlay: MKPolyline{
    }
    class SmallPathOverlay: MKPolyline{
    }
    
    // XMLParser additions
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qname: String?, attributes attributeDict: [String : String] = [:]) {
        
        
        if elementName == "trkpt" {
            lat = attributeDict["lat"]!
            long = attributeDict["lon"]!        }
        
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "trkpt" {

            //  pointData contains CSV String of lat, long, hacc, vacc, elev ,??, date
            let point: String = lat + "," + long + ",0,0," + ele + "," + date
            pointData.append(point)
            //  gPXTracks.append(GPXTrack(long: long, lat: lat, date: date, ele: ele))
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "time" {
                self.date = data
            }
            else if self.elementName == "ele" {
                self.ele = data
            }
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XMLParser parserDidStartDocument")
    }
    
    func parser(_ parser: XMLParser,
    didStartMappingPrefix prefix: String,
    toURI namespaceURI: String) {
        print("XMLParser didStartMappingPrefix: \(prefix)")
    }
}
