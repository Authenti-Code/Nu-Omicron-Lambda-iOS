//
//  ForgotPasswordViewController.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import IQKeyboardManager
import  SVProgressHUD
class ForgotPasswordViewController: UIViewController,APIsDelegate {
    @IBOutlet weak var emailTF: UITextField!
    //MARK:- Outlets
    @IBOutlet weak var imgView:   UIImageView?
    @IBOutlet weak var emailView: UIView?
    @IBOutlet weak var doneBtnView: UIView?
    
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         API.shared.deligate = self
        theme()
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    
    func theme(){
        emailView?.backgroundColor = UIColor.white
        emailView?.layer.borderColor = borderCol.cgColor
        emailView?.layer.borderWidth = 1
        emailView?.layer.cornerRadius = 25
        emailView?.clipsToBounds = true
        //Done button
        doneBtnView?.backgroundColor = backGroundColor
        doneBtnView?.layer.cornerRadius = 25
        doneBtnView?.clipsToBounds = true
        
        
    }
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        if emailTF?.text?.count == 0{
            self.showAlert(text: "Please enter email address")
            return
        }
        var params = [String:String]()
        params = [
                  "email":emailTF?.text ?? ""
                  
        ]
        API.shared.forgotPassword(url: API_ENDPOINTS.FORGOT_PASSWORD.rawValue, params: params, viewController: self) { (respo) in
            print(respo)
            var data = respo["data"] as! [String:Any]
//            self.showAlert(text: data["message"] as! String)
            var refreshAlert = UIAlertController(title: "Success", message: data["message"] as! String, preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
               self.navigationController?.popViewController(animated: true)
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
}
