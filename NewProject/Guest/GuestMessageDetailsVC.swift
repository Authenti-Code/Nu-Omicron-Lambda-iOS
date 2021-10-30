//
//  GuestMessageDetailsVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 13/03/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit
import SDWebImage
class GuestMessageDetailsVC: UIViewController,APIsDelegate,WKNavigationDelegate {
    var data = [String:Any]()
    var id: String = ""
    
    @IBOutlet weak var outerviewHeight: NSLayoutConstraint!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgHeader: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data)
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
         webView.navigationDelegate = self
        getData()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
//        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + lblDescription.intrinsicContentSize.height - 200)
        
    }
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["id": "\(id)"]
        
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_GUEST_MESSAGE_DETAILS.rawValue, viewController: self, params: params) { (response) in
            print(response)
            let data1 = response["data"] as! [String : Any]
            self.lblTitle.text = data1["name"] as! String
            
            let detailItem = data1["details"] as? String ?? ""
            
            let html = """
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style> body { font-size: 90%; } </style>
            </head>
            <body>
            \(detailItem)
            </body>
            </html>
            """
            
            self.webView.loadHTMLString(html, baseURL: nil)
            
//            self.lblDescription.attributedText = (data1["details"] as? String)?.htmlToAttributedString
            let date = data1["created_at"] as! String
            var dateString = date.components(separatedBy: " ")
            
            self.lblDate.text = Utility.formatDateMessage(date: date)
            self.lblTime.text = Utility.formatTimeNew(str: date)
            
            if let image = data1["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_GUEST_MESSAGE.rawValue +  (data1["image"] as! String))!
                self.imgHeader.sd_imageIndicator = SDWebImageActivityIndicator.gray
                
                self.imgHeader.sd_setImage(with: imageURL)
            }
            
//            self.imgHeader.imageFromServerURL(urlString: )
        }
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
  

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if components?.scheme == "http" || components?.scheme == "https"
            {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.webViewHeight.constant = height as! CGFloat
                    self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height/2) + (height as! CGFloat))
                    self.outerviewHeight.constant = ((UIScreen.main.bounds.height/2) + (height as! CGFloat))
                    
                })
            }
            
        })
        //        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
        //            print("----------")
        //            print(height as! CGFloat)
        //            self.webviewHeight?.constant = height as! CGFloat
        //            self.uiScroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + (height as! CGFloat))
        //
        //        })
    }
}
