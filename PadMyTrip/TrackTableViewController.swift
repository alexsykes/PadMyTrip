//
//  TrackTableViewController.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class TrackTableViewController: UITableViewController, UIDocumentPickerDelegate {
    var files :[URL]! = []
    var tracks :[Track] = []
    var mapViewController = MapViewController(nibName: "mapViewController", bundle: nil)
    var mapView :MKMapView!
    var currentMap :Map!
    var map :MapData!
    var trackData: [TrackData]!
    
    var mapLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    // @IBOutlet weak var trackCell: TrackViewCell!
    @IBOutlet var trackTableView: UITableView!
    
    // MARK: Button actions
    // Action for adding tracks from public folders
    @IBAction func addTracks(_ sender: UIBarButtonItem) {
        addTracksFromPublic()
    }
    
    @IBAction func saveMapData(_ sender: UIBarButtonItem) {
        // Encode data then write to disk
        saveFileData()
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        trackTableView.delegate = self
        
        currentMap = Map(name: "Line 38", mapDescription: "Line 38 description")
        
        // Read saved map data
        map = MapData(name: "Map name", mapDescription: "A description of my map", date: Date(), northMost: -90, southMost: 90, westMost: -180, eastMost: 180, trackData: [])
        
        readStoredJSONData()
        trackData = map.trackData
        
    }
    
    
    // MARK: File Handling
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
    
    // MARK: Write file data
    func saveFileData() {
        // Encode data then write to disk
        let data :Data = encode()
        writeData(data: data)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TrackViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackViewCell
        //  let file = files[indexPath.row]
        let track = trackData[indexPath.row]
        //        let  name = file.lastPathComponent
        //        let path = file.path
        //        let date = ((try? FileManager.default.attributesOfItem(atPath: path))?[.creationDate] as? Date)!
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .short
        //        dateFormatter.timeStyle = .short
        //        dateFormatter.doesRelativeDateFormatting = true
        //        let timStr = dateFormatter.string(from: date)
        //
        //        cell.textLabel?.text = name
        //        cell.subtitle?text = "Date"
        cell.titleLabel?.text = "\(track.name)"
        //   cell.subtitleLabel?.text = timStr
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //            let fileManager = FileManager.init()
            //            let file = files[indexPath.row]
            //            do {
            //                try fileManager.removeItem(at: file)
            //            } catch {
            //                print("Error deleting file: \(error.localizedDescription)")
            //            }
            // Delete the row from the data source
            trackData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: File Handling
    /* Presents user with a dialog box u
     user selects a file or files
     then the documentPicker didPickDocumentsAt event is fired
     */
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
    
    
    // MARK: functions
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
    
    func encodeOld () -> Data {
        var encodedData :Data!
        // Structs - MapData, Location, TrackData
        var points :[Location] = []
        var dataToSave :[TrackData] = []
        
        // Work through data track by track :: point by point
        // Each track comprises a set of points
        for track in trackData {
            
            // For each track, add each location to the points array
            
            // Firstly, start with an empty array
            var points :[Location] = []
            for point in track.points {
                
                // Add the data for each point
                let lat = point.lat
                let long = point.long
                let elevation = point.elevation
                
                let point = Location.init(long: long, lat: lat, elevation: elevation)
                // then append to the array
                points.append(point)
            }
            // Once the tack points array is populated,
            // append the array of points to the trackData
            
            dataToSave.removeAll()
            dataToSave.append(TrackData.init(name:"Track name",points: points))
            // encodedData = Data(dataToSave.utf8)
            //return encodedData
        }
        
        let mapData = MapData(name: map.name, mapDescription: map.mapDescription, date: Date(), northMost: map.northMost, southMost: map.southMost, westMost: map.westMost, eastMost: map.eastMost, trackData: trackData)
        
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mapData) {
            if let json = String(data: encoded, encoding: .utf8) {
                print(json)
            }
            encodedData = encoded
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(MapData.self, from: encoded) {
                print(decoded)
            }
        }
        return encodedData
    }
    
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
            if let json = String(data: encoded, encoding: .utf8) {
                // print(json)
            }
            encodedData = encoded
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(MapData.self, from: encoded) {
                // print(decoded)
            }
            
            
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
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // Identify selected row and pass data to MapView function
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print("Selected row: \(row)")
        let track = trackData[row]
        
       // mapLabel = mapViewController.mapLabel
       // mapLabel.text = "Hello"
        
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        guard let MapViewController = segue.destination as? MapViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedTrackCell = sender as? TrackViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedTrackCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedTrack = trackData[indexPath.row]
        let selectedRow = indexPath.row
        MapViewController.trackRow =  selectedRow
     
     
     
     }
     
    
    
    // MARK: Note re cell greying
    /* Use the UITableViewDelegate method tableView:didSelectRowAtIndexPath: to detect which row is tapped (this is what exactly your tapGesture is going to do) and then do your desired processing.
     If you don't like the gray indication when you select cell, type this in your tableView:didEndDisplayingCell:forRowAtIndexPath: just before returning the cell:
     cell?.selectionStyle = .None
     
     
     override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     cell.selectionStyle = .none
     }
     
     */
    
}
