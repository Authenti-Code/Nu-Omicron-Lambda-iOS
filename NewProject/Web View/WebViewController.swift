//
//  WebViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 27/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: UIViewController {

    @IBAction func onShareNew(_ sender: UIButton) {
        if let myWebsite = NSURL(string: url) {
            let objectsToShare = ["Documents", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var btnShareNew: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    var url: String = ""
    var name: String = ""
    var isDoc = false
    
    @IBOutlet weak var imgShare: UIImageView!
    @IBAction func onShare(_ sender: UIButton) {
        if let myWebsite = NSURL(string: url) {
            let objectsToShare = ["Documents", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnShare.isHidden = true
        lblTitle.text = name
        if !isDoc {
            btnShare.isHidden = true
            imgShare.isHidden = true
            btnShareNew.isHidden = true
        }
        let myURL = URL(string:url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
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
