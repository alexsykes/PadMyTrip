//
//  MapViewController.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIDocumentPickerDelegate  {
    
    // MARK: Properties
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    var files = [URL]()
    
    @IBOutlet weak var importTracks: UIBarButtonItem!
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // Do any additional setup after loading the view.
        
        getPermissions()
        
        setUpMap()
        //        getFileList()
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
        //  locationManager.startUpdatingLocation()//
        //   locationManager.startUpdatingHeading()
        // bgLocation = defaults.bool(forKey: "bgLocation")
    }
    
    @IBAction func importTracks(_ sender: UIBarButtonItem) {
                readFromPublic()
    }
    
    func setUpMap() {
        mapView.mapType = .standard
        // mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        // mapView.showsCompass = true
    }
    
    //    // MARK: File Handling
    //    func getDocumentsDirectory() -> URL {
    //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //        // let public = FileManager
    //        return paths[0]
    //    }
    //
    //
    //    func getFileList() {
    //        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    //        let skipsHiddenFiles: Bool = true
    //
    //        let URLs = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
    //
    //        var csvURLs = URLs.filter{ $0.pathExtension == "csv" || $0.pathExtension == "txt"}
    //        csvURLs.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() } )
    //
    //     //   let URLs = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil)
    //        for file in csvURLs {
    //            files.append(file)
    //        }
    //    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // Documents picked
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        var trackFiles = urls
        // Add check for zero return
        if urls.count == 0 { return}
        do {
           try  readReturnedTracks(trackURLs: urls)
        } catch {
            print("Error reading returned files: \(error.localizedDescription)")
        }
    }
    
    func readReturnedTracks(trackURLs :[URL]) throws {
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

}
