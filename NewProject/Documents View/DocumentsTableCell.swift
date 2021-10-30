//
//  DocumentsTableCell.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class DocumentsTableCell: UITableViewCell {
    
    @IBOutlet weak var outerView: UIView?
    @IBOutlet weak var docsLbl: UILabel?
    @IBOutlet weak var imgView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
