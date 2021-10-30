//
//  PeopleGoingTableCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class PeopleGoingTableCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
