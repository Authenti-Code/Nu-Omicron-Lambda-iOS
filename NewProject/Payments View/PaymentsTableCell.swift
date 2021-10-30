//
//  PaymentsTableCell.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class PaymentsTableCell: UITableViewCell {

    @IBOutlet weak var paymentLbl: UILabel?
    @IBOutlet weak var paymentView: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
