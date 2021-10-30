//
//  ViewController.swift
//  NewProject
//
//  Created by osx on 22/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SideMenuSwift
import IQKeyboardManager
import SVProgressHUD
import Alamofire
import SDWebImage
import SwiftKeychainWrapper
import AdSupport

class ViewController: UIViewController,APIsDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var emailView:  UIView?
    @IBOutlet weak var passwordView: UIView?
        
    @IBOutlet weak var emailTF: UITextField?
    @IBOutlet weak var passwordTF: UITextField?
    
    @IBOutlet weak var errorView: UIView?
    @IBOutlet weak var errorLbl: UILabel?
    @IBOutlet weak var loginView: UIView?
    @IBOutlet weak var passwordErrorView: UIView?
    @IBOutlet weak var passwordErrorLbl: UILabel?
    
    @IBOutlet weak var imageSlider: UICollectionView!
    @IBOutlet weak var imgAdd3: UIImageView!
    @IBOutlet weak var imgAdd2: UIImageView!
    @IBOutlet weak var imgAdd1: UIImageView!
    let borderColor : UIColor = UIColor(red: 185/255, green: 156/255, blue: 57/255, alpha: 0.3)
    var addsDataSource: [[String:Any]]?
    
    //MARK:- View Life-Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        imageSlider.dataSource = self
             imageSlider.delegate = self
        API.shared.deligate = self
        navigationController?.navigationBar.isHidden = true
       
        hideKeyboard()
        passwordTheme()
        let cellWidth : CGFloat = imageSlider.frame.size.width / 3.5
                 let cellheight : CGFloat = cellWidth
                 let cellSize = CGSize(width: cellWidth , height:cellheight)
                 
                 let layout = UICollectionViewFlowLayout()
                 layout.scrollDirection = .horizontal //.horizontal
                 layout.itemSize = cellSize
                 layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
                 layout.minimumLineSpacing = 1.0
                 layout.minimumInteritemSpacing = 1.0
                 imageSlider.setCollectionViewLayout(layout, animated: true)
                 imageSlider.reloadData()
        getAdds()
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let index = tappedImage.tag
        print(index)
        openLink(str: addsDataSource?[index]["url"] as! String)
        // Your action
    }
    func openLink(str: String) {
        guard let url = URL(string: str) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @objc func imageTapped(tapGestureRecognizer1: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer1.view as! UIImageView
        let index = tappedImage.tag
        print(index)
        openLink(str: addsDataSource?[index]["url"] as! String)
        // Your action
    }
    @objc func imageTapped(tapGestureRecognizer2: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer2.view as! UIImageView
        let index = tappedImage.tag
        print(index)
        openLink(str: addsDataSource?[index]["url"] as! String)
        // Your action
    }
    public func callBackFromAPI(){
         SVProgressHUD.dismiss()
    }
    
    @IBAction func forgotActionBtn(_ sender: Any){
        
    }
    
    @IBAction func signupActionBtn(_ sender: Any) {
    }
    
    @IBAction func loginActionBtn(_ sender: Any) {
       if !validateFields(){
        return
        }
       else {
        
        login()
        }
}
    
    func login(){
       // api.delegate = self
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        
        print(UIDevice.current.identifierForVendor!.uuidString)
        var params = [String:String]()

        /// Get Permanent Udid when user delete app and install agian.
        if let previousDeviceId = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CurrentDeviceId") {
            params = ["email": emailTF?.text ?? "","password": passwordTF?.text ?? "","device_type": "ios",
                      "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "NO_DEVICE_TOKEN_FOUND","device_id":"\(String(describing: previousDeviceId))"]
        } else {
            params = ["email": emailTF?.text ?? "","password": passwordTF?.text ?? "","device_type": "ios",
                      "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "NO_DEVICE_TOKEN_FOUND","device_id":"\(String(describing: UIDevice.current.identifierForVendor!.uuidString))"]
            KeychainWrapper.defaultKeychainWrapper.set(UIDevice.current.identifierForVendor!.uuidString, forKey: "CurrentDeviceId")
        }
        SVProgressHUD.show()
        
        /// Get Permanent Udid when user delete app and install agian.
//        let id = ASIdentifierManager.shared().advertisingIdentifier
        
        API.shared.loginUser(url: API_ENDPOINTS.LOGIN.rawValue, viewController: self, params: params) { (response) in
            var data = response["data"] as! [String: Any]
            let token = data["token"] as! String
            UserDefaults.standard.set(token, forKey: "token")
            var user = data["user"] as! [String :Any]
            let email = user["email"] as! String
            let id = user["id"] as! Int
            let name = user["name"] as! String
            let dob = user["dob"] as? String
            let phone = user["mobile"] as? String
            let city = user["city"] as? String
            let state = user["state"] as? String
            let website = user["website"] as? String
            let is_notify = user["is_notify"] as? String
              let lifetime_number = user["lifetime_number"] as? String
             let id_number = user["alpha_id"] as? String
            let profile_image = user["profile_image"] as? String
            var role = user["role"] as! [String :Any]
            let permission = role["permission"] as! [[String :Any]]
            var permissionArray = [Permissions]()
            if let  description = user["description"] as? String{
                UserDefaults.standard.set(description, forKey: "description")
            }else{
                UserDefaults.standard.set("", forKey: "description")
            }
            for item in permission{
                print(item)
                 let itemA = Permissions(json:["id": item["id"] as! Int, "name": item["name"] as! String])
                permissionArray.append(itemA)
            }
            print(permissionArray)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: permissionArray)
            UserDefaults.standard.set(encodedData, forKey: "permissions")
            let uid = String(id)
            UserDefaults.standard.set(uid, forKey: "id")
            UserDefaults.standard.set(name, forKey: "name")
            UserDefaults.standard.set(dob, forKey: "dob")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(phone, forKey: "phone")
            UserDefaults.standard.set(is_notify, forKey: "is_notify")
            UserDefaults.standard.set(city, forKey: "city")
            UserDefaults.standard.set(state, forKey: "state")
            UserDefaults.standard.set(website, forKey: "website")
            UserDefaults.standard.set(id_number, forKey: "alpha_id")
            UserDefaults.standard.set(lifetime_number, forKey: "lifetime_number")
            UserDefaults.standard.set(profile_image, forKey: "profile_image")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
                let navigationController = UINavigationController(rootViewController: nextViewController)
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.window!.rootViewController = navigationController
        
    }
}
    
    func getAdds() {
        var params = [String:String]()
        params = ["key": "3p2ddt8bb3plmhuafvsqrzhrp0ptei7r"]; Alamofire.request("https://apa1906.app/api/adds", method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
               print( )
               if let response = response.result.value! as? [String : Any] {
                    print(response)
                if let adds = response["data"] as? [[String: Any]]{
                    self.addsDataSource = adds
                   self.imageSlider.reloadData()
                }
               }
                break
            case .failure(_):
//                print( response.result.value!)
                break
            }
            
        }
    }
    
    func passwordTheme(){
      
        emailView?.customBorder()
//        emailView?.layer.borderColor = borderColor.cgColor
//        emailView?.layer.borderWidth = 1
//        emailView?.layer.cornerRadius = 30.0
//        emailView?.clipsToBounds = true
        
        passwordView?.customBorder()
//        passwordView?.layer.borderColor = borderColor.cgColor
//        passwordView?.layer.borderWidth = 1
//        passwordView?.layer.cornerRadius = 30.0
//        passwordView?.clipsToBounds = true
        
        loginView?.backgroundColor = backGroundColor
        loginView?.layer.cornerRadius = 25.0
        loginView?.clipsToBounds = true
    }
    
    
    func checkValidateEmail(text: String) -> Bool{
     
        if text == ""{
            errorLbl?.text = "Enter Email"
            return false
        }
        if !text.isValidEmail{
            errorLbl?.text = "Not a valid Email"
            return false
        }
        errorLbl?.text = ""
        return true
    }

    func checkValidatePassword(text: String) -> Bool{
        
        if text == ""{
            passwordErrorLbl?.text = "Enter Password"
            return false
        }
        passwordErrorLbl?.text = ""

    
        return true
    }

    func validateFields() -> Bool{
       
        let isEmailVerified = checkValidateEmail(text: emailTF?.text ?? "")
        let isPassValid =  checkValidatePassword(text: passwordTF?.text ?? "")
        if !isEmailVerified || !isPassValid{
            return false
        }
        return true
    }
    
    func alert(message: String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)

    }
    
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardByTappingOutside))
         tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboardByTappingOutside() {
        self.view.endEditing(true)
    }
    
}

extension UIView{
    func customBorder(){
        layer.backgroundColor = backgroundColor?.cgColor
        layer.borderColor = borderCol.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 25.0
        clipsToBounds = true
    }
    
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCollectionViewCell", for: indexPath as IndexPath) as! AddCollectionViewCell
            let image: String = "https://apa1906.app/uploads/adds/" + (addsDataSource?[indexPath.row]["image"] as? String ?? "")
            print(image)
//            cell.image.pin_setImage(from: URL(string: image)!)
            let imageURL = URL(string: image)!
            cell.image.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.image.sd_setImage(with: imageURL)
//        var image: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["attachment"] as? String ?? "")
       
//        cell.imgPhoto.imageFromServerURL(urlString: API_URLS.BASE_URL_MEDIA.rawValue +  (dataSource[indexPath.row]["message"] as! String))
//        var user = users[indexPath.row]["user"] as! [String:Any]
//        cell.lblName.text = user["name"] as! String
        return cell
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 2;
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 1;
    }
    
    
    //UICollectionViewDatasource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return addsDataSource?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
      
        if let  image = addsDataSource?[indexPath.row]["image"] as? String{
            
          openLink(str: addsDataSource?[indexPath.row]["url"] as! String)
        }
       
    }
    
    
}
