//
//  SettingsViewController.swift
//  PadMyTrip
//
//  Created by Alex on 08/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit

protocol SettingsDelegate: AnyObject {
    func userDidEnterInformation(mapDetails: [String])
}

class SettingsViewController: UIViewController {
  //  var mapDelegate: MapDelegate!
    var mainViewController :MainViewController?
    var mapName :String!
    var mapDescription :String!
    
    weak var delegate: SettingsDelegate? = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameInput: UITextField?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = "Map name"
        descriptionLabel.text = "Map Description"
        nameInput?.text = mapName
        descriptionText?.text = mapDescription
        descriptionText!.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
 
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        var data :[String] = []
        data.append(mapName!)
        data.append(mapDescription!)
        
      //  mapDelegate?.onCompletion(dataFromSettings: data)
    }
    
    @IBAction func saveSettings(_ sender: UIBarButtonItem) {
        var mapDetails  :[String] = []
        let mapName = nameInput!.text!
        let mapDescription = descriptionText!.text!
        mapDetails.append(mapName)
        mapDetails.append(mapDescription)
        
        delegate?.userDidEnterInformation(mapDetails: mapDetails)
        _ = self.navigationController?.popViewController(animated: true)
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
