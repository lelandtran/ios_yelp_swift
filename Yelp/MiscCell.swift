//
//  MiscCell.swift
//  Yelp
//
//  Created by Tran, Leland on 4/6/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit


class MiscCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
