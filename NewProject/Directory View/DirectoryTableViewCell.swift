//
//  DirectoryTableViewCell.swift
//  NewProject
//
//  Created by osx on 22/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class DirectoryTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    
    @IBOutlet weak var imgOuterView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
