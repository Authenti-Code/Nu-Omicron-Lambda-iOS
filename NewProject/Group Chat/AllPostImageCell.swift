//
//  AllPostImageCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 21/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class AllPostImageCell: UITableViewCell {

    @IBOutlet weak var imageHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var chatContainerview: UIView!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var lblTime: NSLayoutConstraint!
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
