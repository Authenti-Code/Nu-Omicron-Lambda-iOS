//
//  NewsTickerDetailsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 14/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit
import SDWebImage
class NewsTickerDetailsViewController: UIViewController,APIsDelegate,WKNavigationDelegate {
    
    @IBOutlet weak var outerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    var data = [String:Any]()
    var id: String = ""
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
   
    @IBOutlet weak var lbldate: UILabel!
    @IBOutlet weak var imgHeader: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
//        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + lblDescription.intrinsicContentSize.height - 200)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         webView.navigationDelegate = self
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getData()

        // Do any additional setup after loading the view.
    }
    
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["id": "\(id)"]
        
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_NEWS_DETAILS.rawValue, viewController: self, params: params) { (response) in
            print(response)
            let data1 = response["data"] as! [String : Any]
            self.lblTitle.text = data1["name"] as? String
//            self.lblDescription.attributedText = (data1["description"] as? String)?.htmlToAttributedString
            let detailItem = data1["description"] as? String ?? ""
            
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
            
            
            self.lbldate.text = Utility.formatDate(date: data1["date"] as! String)
//                    let from = data1["from_time"] as? String ?? ""
//                    let to = data1["to_time"] as? String ?? ""
//                    let time = Utility.formatTime(str: from)  + " - " + Utility.formatTime(str: to)
            self.lblTime.text = ""
//            self.imgHeader.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_NEWS.rawValue +  (data1["image"] as! String))
            if let image = data1["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_NEWS.rawValue + image)!
                self.imgHeader.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgHeader.sd_setImage(with: imageURL)
            }
           
        }
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
                     self.outerViewHeight.constant = ((UIScreen.main.bounds.height/2) + (height as! CGFloat))
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
