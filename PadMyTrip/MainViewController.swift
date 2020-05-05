//
//  MainViewController.swift
//  PadMyTrip
//
//  Created by Alex on 05/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  let tableView = UITableView(frame: .zero, style: .plain)
      //  tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        // Do any additional setup after loading the view.
     //   tableView.reloadData()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        return 10 // trackData.count
    }
    
    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TrackViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackTableCell", for: indexPath) as! TrackViewCell
        //  let file = files[indexPath.row]
        // let track = trackData[indexPath.row]
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
        cell.titleLabel?.text = "Text"
        //   cell.subtitleLabel?.text = timStr
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
            //            let fileManager = FileManager.init()
            //            let file = files[indexPath.row]
            //            do {
            //                try fileManager.removeItem(at: file)
            //            } catch {
            //                print("Error deleting file: \(error.localizedDescription)")
            //            }
            // Delete the row from the data source
            //  trackData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackTableCell", for: indexPath) as! TrackViewCell
        //  let file = files[indexPath.row]
        // let track = trackData[indexPath.row]
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
        cell.titleLabel?.text = "Text"
        //   cell.subtitleLabel?.text = timStr
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        mapView.mapType = .satellite
        print("Clicked: \(row) ")
    }
    
}
