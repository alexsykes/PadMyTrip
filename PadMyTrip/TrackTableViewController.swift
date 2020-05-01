//
//  TrackTableViewController.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit

class TrackTableViewController: UITableViewController {
    var files :[URL]! = []
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trackCell: TrackViewCell!
    @IBOutlet var trackTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getFileList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getFileList()
    }
    
    
    // MARK: File Handling
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // let public = FileManager
        return paths[0]
    }
    
    
    func getFileList() {
        files.removeAll()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
        let skipsHiddenFiles: Bool = true
        
        let URLs = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        
        var csvURLs = URLs.filter{ $0.pathExtension == "csv" || $0.pathExtension == "txt"}
        csvURLs.sort(by: { $0.lastPathComponent.lowercased() < $1.lastPathComponent.lowercased() } )
        
        for file in csvURLs {
            files.append(file)
        }
    }
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackViewCell
        let file = files[indexPath.row]
        let  name = file.lastPathComponent
        cell.textLabel?.text = name
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
