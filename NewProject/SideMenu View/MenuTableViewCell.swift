//
//  MenuTableViewCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 05/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imgImage: UIImageView!
    @IBOutlet weak var imgIcon: NSLayoutConstraint!
    @IBOutlet weak var lblItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
