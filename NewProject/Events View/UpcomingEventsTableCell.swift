//
//  UpcomingEventsTableCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 18/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class UpcomingEventsTableCell: UITableViewCell {

    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblGoing: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var dateLbl: UILabel?
    @IBOutlet weak var calanderBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
