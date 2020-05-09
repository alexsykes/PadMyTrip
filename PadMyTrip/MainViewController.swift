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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, MKMapViewDelegate, SettingsDelegate   {
    
    func userDidEnterInformation(mapDetails: [String]) {
        currentMap.name = mapDetails[0]
        currentMap.mapDescription = mapDetails[1]
        map.name = mapDetails[0]
        map.mapDescription = mapDetails[1]
    }
    

    // MARK: Properties
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackTableView: UITableView!
    
    // MARK: Variables
    var files :[URL]! = []
 //   var mapViewController = MapViewController(nibName: "mapViewController", bundle: nil)
    var currentMap :Map!            // Map class - used to hold data displayed on MKMapView
    var map :MapData!               // Struct representing a Map used for storing data in Codable format
    var tracks :[Track] = []
    var polylines :[MKPolyline] = []
    var trackIndex: Int!
    var overlays :[MKOverlay]!
    
    // var trackData: [TrackData]!
    
    // MARK: Actions
    // + Button clicked
    @IBAction func addFromPublic(_ sender: UIBarButtonItem) {
        presentFilePicker()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegation
        mapView.delegate = self
        trackTableView.dataSource = self
        trackTableView.delegate = self
        trackTableView.allowsMultipleSelection = true
        
        // Setup currentMap and populate from data in JSON data
        loadSavedMapData()
        currentMap = Map(mapData: map)
        // At this point, all tracks are loaded from storage.
        
        // Check that there are tracks on the map - possibly only one track with no points!
        if currentMap.trackData.count > 0 {
         // getTracks()
            currentMap.calcBounds()
            print("Track data count: \(currentMap.trackData.count)")
            
        }
        // At this stage, all saved mapdat has been imported
        mapView.region =  currentMap.region
        self.title = currentMap.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(true)
        self.title = currentMap.name

     }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveFileData()
    }
    
    // MARK: Load svaed map data
    func loadSavedMapData () {
        // Read saved map data into Mapdata struct
        map = MapData(name: "Map name", mapDescription: "A description of my map", date: Date(),  trackData: [])
        readStoredJSONData()
        map.trackData.sort(by: {$0.name.lowercased() < $1.name.lowercased()} )
        
        /* MARK:  At this point -
         currentMap holds default data as in Line 48 above
         map contains sored data read from storage
         */
        /*
        currentMap.name = map.name
        currentMap.mapDescription = map.mapDescription
        currentMap.date = map.date
        if map.trackData.count > 0 {
            for track in map.trackData {
                
                var location :CLLocation!
                var locations :[CLLocation] = []
                
                if track.points.count > 0 {
                    for point in track.points {
                        location = CLLocation(latitude: point.lat, longitude: point.long)
                        locations.append(location)
                    }
                    let newTrack :Track = Track(track: locations)
                    currentMap.addTrack(track: newTrack )
                }
            }
        }
        */
    }
    
    // MARK: Getting tracks for display
    func getTracks() {
        // Track polylines need to be created
        // Polylines need to be drawn
        
        for track in currentMap.tracks {
            // Check that track contains data
            if track.locations.count > 0 {
                let polyline = track.getPolyline()
                polylines.append(polyline)
                mapView.addOverlay(polyline)
            }
        }
        currentMap.calcBounds()
    }
    
    
    
    // MARK: Write file data
    func saveFileData() {
        // Encode data then write to disk
        let data :Data = encode()
        writeData(data: data)
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
                for point in pointData {
                    let location = point.split(separator: ",")
                    let lat = Double(location[0])!
                    let long = Double(location[1])!
                    let elev = Double(location[2])!
                    
                    let newLocation = Location(long: long, lat: lat, elevation: elev)
                    points.append(newLocation)
                }
                map.trackData.append(TrackData.init(name:filename,points: points))
                // NEED TO ADD TRACK FOR CURRENT MAP HERE
                // Add new polyline from track here
                let track :Track = Track(points: points)
                currentMap.addTrack(track: track)
                let polyline = track.getPolyline()
                polylines.append(polyline)
                mapView.addOverlay(polyline)
                // Update and set region
                // mapView.region = currentMap.calcBounds()

                // Finally, remove the imported file
                try
                    fileManager.removeItem(at: newFileURL)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
    }
    
    /*
 func importAndConvertToJSON(trackURL :URL, newFileURL :URL) throws {
        let fileManager = FileManager.init()
        do {
            try
                fileManager.copyItem(at: trackURL, to: newFileURL)
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
 */
    
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
    
    func encode () -> Data {
        var encodedData :Data!
        // Structs - MapData, Location, TrackData
        // var points :[Location] = []
        var tData :[TrackData] = []
        
        // Work through data track by track :: point by point
        // Each track comprises a set of points
        for track in map.trackData {
            
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
        
        let mapData = MapData(name: currentMap.name, mapDescription: currentMap.mapDescription, date: Date(), trackData: tData)
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mapData) {
            encodedData = encoded
        }
        return encodedData
    }
    
    func writeData(data :Data) {
        let longFileName = "MyMap.dat"
        let altFileName = "MyMap.txt"
        let url = self.getDocumentsDirectory().appendingPathComponent(longFileName)
        
        let alt = self.getDocumentsDirectory().appendingPathComponent(altFileName)
        
        do {
            try data.write(to: url)
            try data.write(to: alt)
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
    
    // MARK: MapView functions
    
    // Display tracks on MapView
    func displayTrack(track trackId: Int) {
        let theTrack = map.trackData[trackId]
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
            
            guard let TrackViewController = segue.destination as? TrackViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? TrackViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = self.trackTableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let row = indexPath.row
            let trackData = currentMap.trackData[row]
            TrackViewController.track = trackData
            TrackViewController.trackIndex = row
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
            return  map.trackData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackTableCell", for: indexPath) as! TrackViewCell
            let trackName = currentMap.trackData[indexPath.row].name
            cell.titleLabel?.text = "\(trackName)"
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
                map.trackData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                currentMap.tracks.remove(at: indexPath.row)
                let overlayToRemove = mapView.overlays[indexPath.row]
                mapView.removeOverlay(overlayToRemove)
                // currentMap.region = currentMap.calcBounds()
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
        
        func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            let row = indexPath.row
            print ("Button tapped: \(row)")
        }
}

