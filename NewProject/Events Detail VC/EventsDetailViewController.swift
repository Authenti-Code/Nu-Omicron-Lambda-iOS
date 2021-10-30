//
//  EventsDetailViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 17/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import WebKit

class EventsDetailViewController: UIViewController, WKUIDelegate {

    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let webConfiguration = WKWebViewConfiguration()
        
        let kit = WKWebView(frame: webView.frame
            , configuration: webConfiguration)
        
        webView.uiDelegate = self
        
        let myURL = URL(string:"http://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        self.webView = kit
    }
    
}

