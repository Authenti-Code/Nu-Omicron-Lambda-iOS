//
//  NewsTickerCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 10/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class NewsTickerCell: UITableViewCell {

    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var btnDetails: UIButton!
   
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var profileContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
