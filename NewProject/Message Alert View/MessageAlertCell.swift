//
//  MessageAlertCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 09/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class MessageAlertCell: UITableViewCell {

    @IBOutlet weak var lblTimings: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var oImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
