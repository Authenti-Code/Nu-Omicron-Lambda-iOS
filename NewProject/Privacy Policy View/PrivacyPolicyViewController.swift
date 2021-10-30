//
//  PrivacyPolicyViewController.swift
//  NewProject
//
//  Created by osx on 19/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit
class PrivacyPolicyViewController: UIViewController,APIsDelegate

{

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var code = 0
    var key = "about"
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        if self.code == 0 {
            key = "about"
            self.lblTitle.text = "ABOUT XAL"
        }else if self.code == 1{
            key = "tnc"
            self.lblTitle.text = "TERMS AND CONDITIONS"
        }else if self.code == 2{
            key = "privacy_policy"
            self.lblTitle.text = "PRIVACY POLICY"
        }
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getPrivacy()
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    func getPrivacy()  {
        SVProgressHUD.show()
        API.shared.getConfiguration(url: API_ENDPOINTS.GET_CONFIGURATION.rawValue, viewController: self) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
            if  let url = data[self.key] as? String{
            self.webView.loadHTMLString(url, baseURL: Bundle.main.bundleURL)
            }
        }
    }

    

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
