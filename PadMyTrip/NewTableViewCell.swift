//
//  NewTableViewCell.swift
//  PadMyTrip
//
//  Created by Alex on 15/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import UIKit


protocol NewTableViewCellDelegate: class {
    func buttonTapped(cell: NewTableViewCell )
}

class NewTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsCount: UILabel!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: NewTableViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func button(_ sender: UIButton) {
        self.delegate?.buttonTapped(cell: self)
    }
    
}


