//
//  TrackViewCellWithImage.swift
//  PadMyTrip
//
//  Created by Alex on 14/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit

class TrackViewCellWithImage: UITableViewCell {

    @IBOutlet weak var pointsCount: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
