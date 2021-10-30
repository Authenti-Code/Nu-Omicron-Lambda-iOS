//
//  UpdatePasswordViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 14/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD

class UpdatePasswordViewController: UIViewController,APIsDelegate {

    var password = ""
    var newPassword = ""
    var confirmPassword = ""
    @IBOutlet weak var doneView: UIView!
    @IBAction func onDone(_ sender: Any) {
        password = tvOldPassword.text!
        newPassword = tvNewPassword.text!
        confirmPassword = tvConfirmPassword.text!
        if password.count == 0{
            self.showAlert(text: "Please enter old password")
        }else if newPassword.count == 0 {
             self.showAlert(text: "Please enter new password")
        }else if confirmPassword.count == 0 {
            self.showAlert(text: "Please enter confirm password")
        }else if newPassword != confirmPassword {
            self.showAlert(text: "Password not matched")
        }else{
            // call the api
            var params = [String:String]()
            params = ["password": newPassword,"password_confirmation": confirmPassword]
            SVProgressHUD.show()
            API.shared.resetPassword(url: API_ENDPOINTS.RESET_PASSWORD.rawValue, viewController: self, params: params) { (response) in
                
                var data = response["data"] as! [String: Any]
                self.showAlert(text: data["Message"] as! String)
                self.tvOldPassword.text = ""
                self.tvNewPassword.text = ""
                self.tvConfirmPassword.text = ""
            }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var tvConfirmPassword: UITextField!
    @IBOutlet weak var tvNewPassword: UITextField!
    @IBOutlet weak var tvOldPassword: UITextField!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var oldPasswordView: UIView!
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        oldPasswordView.customBorder()
        newPasswordView.customBorder()
        confirmPasswordView.customBorder()
        doneView?.backgroundColor = backGroundColor
        doneView?.layer.cornerRadius = 25.0
        doneView?.clipsToBounds = true
     
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
