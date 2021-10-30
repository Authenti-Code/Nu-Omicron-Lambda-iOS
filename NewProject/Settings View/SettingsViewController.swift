//
//  SettingsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 06/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class SettingsViewController: UIViewController,APIsDelegate {

    @IBOutlet weak var `switch`: UISwitch!
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var termsAndCondition: UIView!
    @IBOutlet weak var privacyPolicy: UIView!
    @IBOutlet weak var updatePassword: UIView!
    @IBOutlet weak var connectSocialView: UIView?
    var is_notify = "1"
    var id = ""
    
    @IBOutlet weak var lblName: UILabel!
    //MARK:- View Life-Cycle
    
    
    @IBAction func onChange(_ sender: Any) {
        notiOn()
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
   
    func notiOn() {
        SVProgressHUD.show()
        API.shared.getConfiguration(url: API_ENDPOINTS.GET_NOTIFICATION.rawValue, viewController: self) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
            if self.is_notify == "1"{
                UserDefaults.standard.set("0", forKey: "is_notify")
                self.is_notify = "0"
            }else{
                UserDefaults.standard.set("1", forKey: "is_notify")
                self.is_notify = "1"
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        connectSocialView?.addTapGesture(tapNumber: 1, target: self, action: #selector(handleGesture))
        updatePassword?.addTapGesture(tapNumber: 1, target: self, action: #selector(handlePassword))
        privacyPolicy?.addTapGesture(tapNumber: 1, target: self, action: #selector(handlePrivacyPolicy))
        termsAndCondition?.addTapGesture(tapNumber: 1, target: self, action: #selector(handleTermsAndCondiotions))
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = .zero
        container.layer.shadowRadius = 1
        
        self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2
        self.imgUser.clipsToBounds = true
        
        self.imgContainer.layer.cornerRadius = self.imgContainer.frame.size.width / 2
        self.imgContainer.clipsToBounds = true
        is_notify = UserDefaults.standard.string(forKey: "is_notify") ?? "1"
        id = UserDefaults.standard.string(forKey: "id") ?? ""
        if is_notify == "1"{
            `switch`.isOn = true
        }else{
            `switch`.isOn = false
        }
        getUserDetails()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        lblName.text = UserDefaults.standard.string(forKey: "name") ?? ""
        if let image = UserDefaults.standard.string(forKey: "profile_image"){
//            imgUser.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)
            
//            if let image = data["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)!
                self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgUser.sd_setImage(with: imageURL)
//            }
        }
    }
    @IBAction func showProfile(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        var refreshAlert = UIAlertController(title: "Logout", message: "Are you sure", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           refreshAlert.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.logout()
            
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
        
    }
    func getUserDetails(){
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["user_id": id]
        API.shared.getData(url: API_ENDPOINTS.GET_USER_DETAILS.rawValue, viewController: self, params: params) { (response) in
            let data1 = response["data"] as! [String : Any]
            print(data1)
            
            self.is_notify = "\(data1["is_notify"] as? String ?? "1")"
            UserDefaults.standard.set(self.is_notify, forKey: "is_notify")
            if self.is_notify == "1"{
                self.`switch`.isOn = true
            }else{
                self.`switch`.isOn = false
            }
            
        }
    }
    
    func logout(){
        var params = [String:String]()
        params = ["device_type": "ios", "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "0","device_id":"\(String(describing: UIDevice.current.identifierForVendor!.uuidString)))"] as! [String : String]
        SVProgressHUD.show()
        API.shared.getData(url: API_ENDPOINTS.LOGOUT.rawValue, viewController: self, params: params) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
             SVProgressHUD.dismiss()
            
            UserDefaults.standard.set(nil, forKey: "token")
            UserDefaults.standard.set(nil, forKey: "is_guest")
            
            
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.setViewControllers([vc], animated: true)
            
        }
    }
    @objc func handleGesture() {
        guard let socialVC = self.storyboard?.instantiateViewController(withIdentifier: "ConnectSocialViewController") as? ConnectSocialViewController else{
            return
        }
        self.navigationController?.pushViewController(socialVC, animated: true)
        
    }
    @objc func handlePassword() {
        guard let socialVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdatePasswordViewController") as? UpdatePasswordViewController else{
            return
        }
        self.navigationController?.pushViewController(socialVC, animated: true)
        
    }
    @objc func handlePrivacyPolicy() {
        guard let socialVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? PrivacyPolicyViewController else{
            return
        }
        socialVC.code = 2; self.navigationController?.pushViewController(socialVC, animated: true)
        
    }
    @objc func handleTermsAndCondiotions() {
        guard let socialVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? PrivacyPolicyViewController else{
            return
        }
        socialVC.code = 1; self.navigationController?.pushViewController(socialVC, animated: true)
        
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
}


extension UIView {
    
    func addTapGesture(tapNumber: Int, target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer (target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
}
