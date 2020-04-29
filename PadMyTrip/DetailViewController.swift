//
//  DetailViewController.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var files = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFileList()
        // mapView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func getTrackList() {
        
    }
    
    // MARK: Functions
    //
    func getFileList() {
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let skipsHiddenFiles: Bool = true
        
        let URLs = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        
        var csvURLs = URLs.filter{ $0.pathExtension == "csv" || $0.pathExtension == "txt"}
        csvURLs.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() } )
              
        for file in csvURLs {
           files.append(file)
        }
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
