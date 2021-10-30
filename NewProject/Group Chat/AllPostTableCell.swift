//
//  AllPostTableCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 17/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import Foundation

class AllPostTableCell: UITableViewCell {
    
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var imgChatUser: UIImageView!
    
    @IBOutlet weak var newImage: UIImageView!
    
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var chatViewContainer: UIView?
    @IBOutlet weak var viewButtonContainer: UIView?
    
    //MARK:- View Life-Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
