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
    var mapViewController :MapViewController?
    var mapView :MKMapView!
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
   // @IBOutlet weak var trackCell: TrackViewCell!
    @IBOutlet var trackTableView: UITableView!
    
    
    // Action for adding tracks from public folders
    @IBAction func addTracks(_ sender: UIBarButtonItem) {
        readFromPublic()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFileList()
    }

    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getFileList()
    } */
    
    // MARK: File Handling
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileList() {
        // Empty any existing data from file array
        files.removeAll()
        
        // Set pointer to document directory and hide dot files
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
        
        // Get array of file URLs
        let URLs = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        // Filter for csv extension then sort by namne
        var csvURLs = URLs.filter{ $0.pathExtension == "csv"}
        csvURLs.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() } )
        
        // For each file
        for file in csvURLs {
            /*  add file to files array
                convert to array of CLLocation objects
                then convert to track and add to tracks array
             */
            files.append(file)
            let trackData = readFile(url :file)     // trackData -> array of Strings : each line becomes one location in
            let locations :[CLLocation] = prepareLocations(trackData: trackData) // trackLocations -> array of CLLocation to be converted to
            
            let newTrack = Track(name: "Unnamed track", trackDescription: "Description goes here", track: locations)
            tracks.append(newTrack)
          //  currentMap.addTrack(track: newTrack)
            
        }
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TrackViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackViewCell
        let file = files[indexPath.row]
        let  name = file.lastPathComponent
        let path = file.path
        let date = ((try? FileManager.default.attributesOfItem(atPath: path))?[.creationDate] as? Date)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        let timStr = dateFormatter.string(from: date)
        
        //        cell.textLabel?.text = name
        //        cell.subtitle?text = "Date"
        cell.titleLabel?.text = name
        cell.subtitleLabel?.text = timStr
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
            let fileManager = FileManager.init()
            let file = files[indexPath.row]
            do {
                try fileManager.removeItem(at: file)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
            // Delete the row from the data source
            files.remove(at: indexPath.row)
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
    func readFromPublic () {
        
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
           do {
               try copyReturnedTrackURLs(trackURLs: urls)
           } catch {
               print("Error reading returned files: \(error.localizedDescription)")
           }
          getFileList()
          DispatchQueue.main.async { self.trackTableView.reloadData() }
       }
    
    func copyReturnedTrackURLs(trackURLs :[URL]) throws {
        let fileManager = FileManager.init()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let csvURLs = trackURLs.filter{ $0.pathExtension == "csv"}
        for trackURL in csvURLs {
            let filename = trackURL.lastPathComponent
            let newFileUrl = docDir.appendingPathComponent(filename)
            do {
                try  fileManager.copyItem(at: trackURL, to: newFileUrl)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
