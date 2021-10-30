//
//  AboutViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 06/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD
class AboutViewController: UIViewController,APIsDelegate {

    @IBOutlet weak var webkit: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
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
        var params = [String:String]()
        params = ["meta_name": "about"]
        SVProgressHUD.show()
        API.shared.getData(url: API_ENDPOINTS.GET_CONFIGURATION.rawValue, viewController: self, params: params) { (model) in
            print(model)
            let data = model["data"] as! [String : Any]
            var metaContent = data["meta-content"] as! String
            self.webkit.loadHTMLString(metaContent, baseURL: Bundle.main.bundleURL)
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
