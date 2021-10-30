//
//  SignUPViewController.swift
//  NewProject
//
//  Created by osx on 22/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import IQKeyboardManager
import SVProgressHUD
import SwiftKeychainWrapper

class SignUPViewController: UIViewController,APIsDelegate {
    @IBOutlet weak var usernameView: UIView?
    @IBOutlet weak var emailView:    UIView?
    @IBOutlet weak var passwordView: UIView?
    @IBOutlet weak var confirmPassView: UIView?
    @IBOutlet weak var signupView: UIView?
    
    @IBOutlet weak var alphaIdTF: UITextField!
    @IBOutlet weak var alphaIdView: UIView!
    @IBOutlet weak var nameTF: UITextField?
    @IBOutlet weak var emailTF: UITextField?
    @IBOutlet weak var passwordTF: UITextField?
    @IBOutlet weak var confirmPassTF: UITextField?
    
    var datasource = CreateAccountModel()
    
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        theme()
    }
    
    func theme(){
        emailView?.customBorder()
        usernameView?.customBorder()
        passwordView?.customBorder()
        confirmPassView?.customBorder()
        alphaIdView?.customBorder()
        signupView?.backgroundColor = backGroundColor
        signupView?.layer.cornerRadius = 25
        signupView?.clipsToBounds = true
    }
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }

    @IBAction func signUpActionBtn(_ sender: Any) {
        if let _textfieldText = emailTF?.text {
        if _textfieldText.isEmail() {
            print("Okay Email go ahead")
        }else{
            showAlert(text: "Enter a valid email!")
            return
        }
        }
        if Reachability.isConnectedToNetwork(){
           
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        var params = [String:String]()
        /// Get Permanent Udid when user delete app and install agian.
        if let previousDeviceId = KeychainWrapper.defaultKeychainWrapper.string(forKey: "CurrentDeviceId") {

        params = ["name":nameTF?.text ?? "",
            "email":emailTF?.text ?? "",
            "alpha_id":alphaIdTF?.text ?? "",
            "password":passwordTF?.text ?? "",
            "c_password":confirmPassTF?.text ?? "",
            "device_type": "ios",
            "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "NO_DEVICE_TOKEN_FOUND","device_id":"\(String(describing: previousDeviceId))"
             ]
        } else {
            params = ["name":nameTF?.text ?? "",
                "email":emailTF?.text ?? "",
                "alpha_id":alphaIdTF?.text ?? "",
                "password":passwordTF?.text ?? "",
                "c_password":confirmPassTF?.text ?? "",
                "device_type": "ios",
                "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "NO_DEVICE_TOKEN_FOUND","device_id":"\(String(describing: UIDevice.current.identifierForVendor!.uuidString)))"
                 ]
            KeychainWrapper.defaultKeychainWrapper.set(UIDevice.current.identifierForVendor!.uuidString, forKey: "CurrentDeviceId")
        }
        API.shared.createAccount(url: API_ENDPOINTS.CREATE_ACCOUNT.rawValue, params: params, viewController: self) { (respo) in
            print(respo)
            var refreshAlert = UIAlertController(title: "Success", message: "Your account request has been submitted successfully", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
               self.navigationController?.popViewController(animated: true)
            }))
            
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
        
    }
    
    
    
}
