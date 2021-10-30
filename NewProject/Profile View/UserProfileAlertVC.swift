//
//  UserProfileAlertVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 31/12/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SDWebImage
class UserProfileAlertVC: UIViewController,UIAlertDeligate {
    
    func onOkayTapped() {
        
    }
    

    @IBOutlet weak var lblLifetime: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblIdNumber: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    var id_number = ""
    var life_number = ""
    var name = ""
    var email = ""
    var image = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        alertView.layer.cornerRadius = 15
        lblIdNumber.text = "Alpha Id " + id_number
        lblEmail.text = email
        lblLifetime.text = life_number
        lblName.text = name
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.black.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
       if image.count > 0 {
//             self.imgUser.pin_setImage(from: URL(string: image)!)
//         let image1: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (image as! String)
        //            imgUser.pin_setImage(from: URL(string: image1)!)
                    let imageURL = URL(string: image)!
                    self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                               
                    self.imgUser.sd_setImage(with: imageURL)
        }
        
    }
    

    @IBAction func onSubmit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
