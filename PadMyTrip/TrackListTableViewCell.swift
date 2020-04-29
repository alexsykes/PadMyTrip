//
//  TrackListTableViewCell.swift
//  PadMyTrip
//
//  Created by Alex on 29/04/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit

class TrackListTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackVisibilityButton: UIButton!
    @IBOutlet weak var trackLockButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
