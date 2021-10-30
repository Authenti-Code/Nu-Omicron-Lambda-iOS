//
//  ViewProfileController.swift
//  NewProject
//
//  Created by Jatinder Arora on 25/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class ViewProfileController: UIViewController ,APIsDelegate{
    
    @IBOutlet weak var lblLifetimeNumber: UILabel!
    @IBOutlet weak var lblIdNumber: UILabel!
    @IBOutlet weak var edtDesc: UITextView!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    var hideIcon = false
    var id = ""
    @IBOutlet weak var edtName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self ;
        getUserDetails()
        if hideIcon{
            btnChat.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    public func callBackFromAPI(){
        
        SVProgressHUD.dismiss()
    }
    @IBAction func onChat(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnetoOneChatVC") as! OnetoOneChatVC
        vc.receiverId = id
        vc.receiverName = edtName.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var edtWebsite: UITextField!
    @IBOutlet weak var lblCity: UITextField!
    @IBOutlet weak var lblState: UITextField!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblDob: UILabel!
    
    
    
    //API calling
    func getUserDetails(){
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["user_id": id]
        API.shared.getData(url: API_ENDPOINTS.GET_USER_DETAILS.rawValue, viewController: self, params: params) { (response) in
            
            let data1 = response["data"] as! [String : Any]
           
            if let id_number = data1["alpha_id"] as? String {
                self.lblIdNumber.text = "Alpha Id " + id_number
            }
            if let lifetime_number = data1["lifetime_number"] as? String {
                self.lblLifetimeNumber.text = "Lifetime No. " + lifetime_number
            }
            self.edtName.text  = data1["name"] as? String
            self.lblEmail.text =  data1["email"] as? String
            self.lblMobile.text =   data1["mobile"] as? String
            self.lblState.text =   data1["state"] as? String
            self.lblCity.text =   data1["city"] as? String
            self.edtWebsite.text =   data1["website"] as? String
            if let dob =  data1["dob"] as? String{
               
                self.lblDob.text =  Utility.formatDate(date: dob)
            }
            if let description = data1["description"] as? String {
                self.edtDesc.text = description
            }
            if let image = data1["profile_image"] as? String{
                let image1: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (image as! String)
//                self.imgUser.pin_setImage(from: URL(string: image1)!)
                
                
                //            imgUser.pin_setImage(from: URL(string: image1)!)
                            let imageURL = URL(string: image1)!
                            self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                       
                            self.imgUser.sd_setImage(with: imageURL)
                self.imgUser.layer.masksToBounds = false
                //                       self.imgUser.layer.borderColor = UIColor.white.cgColor
                                       self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2
                                       self.imgUser.clipsToBounds = true
                //            imgUser.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)
            }
           
        }
    }

}
