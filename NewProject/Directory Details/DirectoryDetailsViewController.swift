//
//  DirectoryDetailsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 10/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SDWebImage

class DirectoryDetailsViewController: UIViewController {

    @IBOutlet weak var chat: UIButton!
    @IBOutlet weak var btnChat: NSLayoutConstraint!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var profileContainer: UIView!
    var id = 0
    @IBOutlet weak var lstName: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var oJobTittleLbl: UILabel!
    @IBOutlet weak var oPlaceOfEmploymentLbl: UILabel!
    @IBOutlet weak var oUniversityLbl: UILabel!
    
    var data = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        profileContainer.layer.masksToBounds = true
        profileContainer.layer.cornerRadius = 4
        profileContainer.layer.borderColor = #colorLiteral(red: 0.7333333333, green: 0.5529411765, blue: 0.1254901961, alpha: 1)
        profileContainer.layer.borderWidth = 1.0
        id = data["is_exist"] as? Int ?? 0
        lblDescription.text = data["description"] as? String
        lblName.text = data["name"] as? String
        lblName.text = data["name"] as? String
        lblPhone.text = data["phone"] as? String
        lblEmail.text = data["email"] as? String
        if let dob = data["dob"] as? String {
             lblDob.text =  Utility.formatDate(date: (data["dob"] as? String)!)
        }
       
        lblWebsite.text = data["website"] as? String
        lblCity.text = data["city"] as? String
        lblState.text = data["state"] as? String
        oJobTittleLbl.text = data["job_title"] as? String
        oPlaceOfEmploymentLbl.text = data["place_of_employment"] as? String
        oUniversityLbl.text = data["university_college_attended"] as? String
        if let image = data["image"] as? String {
//            imgProfile.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + (data["image"] as! String))
//            if let image = data["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)!
                self.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.white
                self.imgProfile.sd_setImage(with: imageURL)
            self.imgProfile.layer.masksToBounds = false
            self.imgProfile.layer.borderColor = UIColor.white.cgColor
            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
            self.imgProfile.clipsToBounds = true
//            }
            
            lstName.text = data["location"] as? String
        }
        if id == 0{
            chat.isHidden = true
        }
        var senderId = UserDefaults.standard.string(forKey: "id") ?? ""
        if senderId == "\(id)"{
            chat.isHidden = true
        }
         var hideChat = true
        let permissionArray = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "permissions") as! Data) as! [Permissions]
        for permission in permissionArray {
            for item in MenuHandler.getHomeMenu(){
                if item.itemID == permission.itemID{
//                    sideMenu.append(item)
                    if item.itemID == 7{
                        hideChat = false
                    }
                    
                }
            }
        }
        if hideChat{
            chat.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
//    func showAirplay() {
//        let rect = CGRect(x: -100, y: 0, width: 0, height: 0)
//        let airplayVolume = MPVolumeView(frame: rect)
//        airplayVolume.showsVolumeSlider = false
//        self.view.addSubview(airplayVolume)
//        for view: UIView in airplayVolume.subviews {
//            if let button = view as? UIButton {
//                button.sendActions(for: .touchUpInside)
//                break
//            }
//        }
//        airplayVolume.removeFromSuperview()
//    }

    @IBAction func onChat(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnetoOneChatVC") as! OnetoOneChatVC
        vc.receiverId = "\(id)"
        vc.receiverName = lblName.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onWebSiteClick(_ sender: Any) {
        guard let url = URL(string: lblWebsite.text ?? "") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func onEmailClick(_ sender: Any) {
        if let email = lblEmail.text{
            
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
//        let email = lblEmail.text!
    }
    
    @IBAction func onPhoneClick(_ sender: Any) {
        if let zone = lblPhone.text{
            let trimmed = zone.replacingOccurrences(of: " ", with: "")
            
            let phoneURL: URL = URL(string: "telprompt://\(trimmed)")! // Removed white space
            
            if UIApplication.shared.canOpenURL(phoneURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(phoneURL)
                }
            } else {
                // Call facility is not available on your device
            }
        }
//        let zone = lblPhone.text!;
        
    }
    
}
