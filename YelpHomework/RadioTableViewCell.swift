//
//  RadioTableViewCell.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/21/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

class RadioTableViewCell: UITableViewCell {

    
    @IBOutlet weak var downImage: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.filterButton.userInteractionEnabled = false
        
    }

}
