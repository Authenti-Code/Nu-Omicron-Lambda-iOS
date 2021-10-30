//
//  EventsDetailsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 14/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit
import SDWebImage
protocol ChangeEvent {
    func onchange(pos: Int, count: Int)
}
class EventsDetailsViewController: UIViewController,APIsDelegate,WKNavigationDelegate {
    
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var viewPeopleGoing: UIView!
    @IBOutlet weak var uiScroll: UIScrollView!
    @IBOutlet weak var webviewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    var deligate: ChangeEvent?
    var pos = Int()
    @IBOutlet weak var btnGoing: UIButton!
    var data = [String:Any]()
    var users = [[String:Any]]()
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblPersonGoing: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var isPast = false
    
    @IBAction func onBack(_ sender: Any) {
        deligate?.onchange(pos: pos, count: users.count)
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var imgHeader: UIImageView!
    var isAttending = 0
    @IBAction func onGoing(_ sender: Any) {
        eventAttend()
        
    }
    var id : Int = 0
    func eventAttend(){
        // api.delegate = self
        var params = [String:String]()
        params = ["event_id": "\(id)"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.EVENT_ATTEND.rawValue.appending("?event_id=\(id)"), viewController: self, params: params) { (response) in
            print(response)
            let data = response["data"] as! [String : Any]
            self.eventDetails()
        }
    }
    
    
    @IBAction func onViewAll(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventPeopleViewController") as! EventPeopleViewController
        vc.id = self.id
        self.present(vc, animated: true, completion: nil)
    }
    
    func eventAttendList(){
        // api.delegate = self
        var params = [String:String]()
        params = ["event_id": "\(id)"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.EVENT_ATTEND_LIST.rawValue.appending("?event_id=\(id)"), viewController: self, params: params) { (response) in
            print(response)
            let data = response["data"] as! [String : Any]
            self.users = data["data"] as! [[String : Any]]
            //            print(data)
            self.collectionView.reloadData()
            if self.users.count == 0 {
                self.btnViewAll.isHidden = true
                self.viewPeopleGoing.isHidden = true
            }
        }
    }
    func eventDetails(){
        // api.delegate = self
        var params = [String:String]()
        params = ["id": "\(id)"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.EVENT_DETAILS.rawValue.appending("?id=\(id)"), viewController: self, params: params) { (response) in
            print(response)
            let data = response["data"] as! [String : Any]
            
            self.lblDate.text = Utility.formatDate(date: (data["date"] as! String))
            let from = data["from_time"] as! String
            let to = data["to_time"] as! String
            let time : String =   Utility.formatTime(str: from)  +  " - " +   Utility.formatTime(str: to)
            self.lblTime.text = time
            self.lblTitle.text = data["name"] as? String
            //            self.lblDescription.attributedText = (data["description"] as? String)?.htmlToAttributedString
            
            let detailItem = data["description"] as? String ?? ""
            
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
            //            self.webView.loadHTMLString(data["description"] as? String ?? "", baseURL: nil)
            //            self.webView.frame.size.height = 1
            //            self.webView.frame.size = self.webView.scrollView.contentSize
            self.lblPersonGoing.text = "\(data["attendees_cnt"] as! Int)" + " Person going"
            
            //            self.imgHeader.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_EVENTS.rawValue +  (data["image"] as! String))
            
            if let image = data["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_EVENTS.rawValue + image)!
                self.imgHeader.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgHeader.sd_setImage(with: imageURL)
            }
            
            self.isAttending = data["attendees"] as? Int ?? 0
            if self.isAttending == 1 {
                self.btnGoing.isEnabled = false
                self.btnGoing.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
            self.eventAttendList()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+lblDescription.intrinsicContentSize.height)
        //
        let targetSize = CGSize(width: view.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        let cellWidth : CGFloat = collectionView.frame.size.width / 5.0
        let cellheight : CGFloat = 100
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
        if isPast {
            btnGoing.isHidden = true
        }
        webView.navigationDelegate = self
//        print(data)
//        self.id = data["id"] as? Int
        eventDetails()
        // Do any additional setup after loading the view.
    }
    
}

extension EventsDetailsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleGoingCell", for: indexPath as IndexPath) as! PeopleGoingCell
        if let user = users[indexPath.row]["user"] as? [String:Any]{
            cell.lblName.text = user["name"] as? String ?? ""
            if let userImgUrl = user["profile_image"] as? String {
                let image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (user["profile_image"] as? String ?? "")
                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgUser.sd_setImage(with: imageURL)
                cell.imgUser.layer.cornerRadius =  cell.imgUser.layer.frame.height / 2
            } else {
                cell.imgUser.image = UIImage(named: "user")
            }
        }else{
            cell.lblName.text = "W’boro Brother"
            cell.imgUser.image = UIImage(named: "user")
        }
        cell.imgUser.layer.cornerRadius = cell.imgUser.layer.frame.size.height / 2
        return cell
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 4;
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
        
        return users.count
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
                    self.webviewHeight.constant = height as! CGFloat
                    //                    self.uiScroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + (height as! CGFloat))
                    self //+ (height as! CGFloat))
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
