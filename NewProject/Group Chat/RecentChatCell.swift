//
//  RecentChatCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 26/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class RecentChatCell: UITableViewCell {

    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var lblTime: NSLayoutConstraint!
    @IBOutlet weak var lblMessage: UILabel!
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
