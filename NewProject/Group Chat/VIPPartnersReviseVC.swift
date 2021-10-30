//
//  VIPPartnersReviseVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 31/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class VIPPartnersReviseVC: UIViewController, APIsDelegate {
    
    //MARK:- Outlets and Variables
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var dedscTitle: UILabel!
    @IBOutlet weak var collectionVIewA: UICollectionView!
    

    @IBAction func onEmail(_ sender: Any) {
        let data = linkData[globalIndexPath.row]
        if let email = data["email"] as? String{
                   
                   if let url = URL(string: "mailto:\(email)") {
                       if #available(iOS 10.0, *) {
                           UIApplication.shared.open(url)
                       } else {
                           UIApplication.shared.openURL(url)
                       }
                   }
               }
    }
    @IBAction func onWeb(_ sender: Any) {
         let data = linkData[globalIndexPath.row]
        guard let url = URL(string: data["website"] as? String ?? "") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    

    var current_page = 1
    var refreshControl = UIRefreshControl()
    var next_page:String?
    var search = ""
    var linkData = [[String: Any]]()
    var imageArray = [String]()
    var globalIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    
    @IBAction func onPrev(_ sender: Any) {
        if globalIndexPath.row > 0 {
                   let indexPath1: IndexPath?
                   indexPath1 = IndexPath.init(row:  (globalIndexPath.row) - 1, section: (globalIndexPath.section))
                   collectionVIewA.scrollToItem(at: indexPath1!, at: .left, animated: true)
                   globalIndexPath = indexPath1!
               }
    }
    @IBAction func onNext(_ sender: Any) {
        if linkData.count > 1{
                   if globalIndexPath.row <= linkData.count-2{
//                       let indexPath1: IndexPath?
//                       indexPath1 = IndexPath.init(row: (globalIndexPath.row) + 1, section: (globalIndexPath.section))
//                       collectionVIewA.scrollToItem(at: indexPath1!, at: .right, animated: true)
//                       globalIndexPath = indexPath1!
                    let x = CGFloat(globalIndexPath.row + 1) * collectionVIewA.frame.size.width
                    self.collectionVIewA.setContentOffset(CGPoint(x: x, y: self.collectionVIewA.contentOffset.y), animated: true)
                    globalIndexPath.row = globalIndexPath.row + 1
                   }else if(globalIndexPath.row == linkData.count-1){
                    if next_page != nil{
                          SVProgressHUD.show()
                         current_page = current_page + 1
                         getVipPartners()
                     }
                    }
               }

    }
    override func viewDidLoad() {
        collectionVIewA.delegate = self
        collectionVIewA.dataSource = self
        API.shared.deligate = self
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        self.btnPrevious.roundCorners(corners: [.topRight])
        self.btnNext.roundCorners(corners: [.topLeft])
        
        let cellWidth : CGFloat = UIScreen.main.bounds.width
        let cellheight : CGFloat = (UIScreen.main.bounds.height - 58 - 50 - 32)
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionVIewA.setCollectionViewLayout(layout, animated: true)
        
        SVProgressHUD.show()
        getVipPartners()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                 SVProgressHUD.show()
                current_page = current_page + 1
                getVipPartners()
            }
        }
    }
    
    func getVipPartners() {
        SVProgressHUD.show()
            var params = [String:String]()
        // kjcebd3zvlzm2orhubovqhhrvvbycgca
            params = ["key": "3p2ddt8bb3plmhuafvsqrzhrp0ptei7r"]; Alamofire.request("https://apa1906.app/api/partner/list", method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
                SVProgressHUD.dismiss()
                switch(response.result) {
                case .success(_):
                 
                   if let response = response.result.value! as? [String : Any] {
                        print(response)
                    let data1 = response["data"] as! [String : Any]
                    self.linkData =   self.linkData + (data1["data"] as! [[String : Any]])
                    self.next_page = data1["next_page_url"] as? String
                    self.collectionVIewA?.reloadData()
                   }
                    break
                case .failure(_):
                    SVProgressHUD.dismiss()
    //                print( response.result.value!)
                    break
                }
                
            }
        }
    func getVipPartners1(){
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["search": "" ,"limit": "20","page": "\(current_page)"]
        API.shared.getData(url: API_ENDPOINTS.GET_PARTNER.rawValue, viewController: self, params: params) { (response) in
            print(response)
            let data1 = response["data"] as! [String : Any]
            self.linkData =   self.linkData + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.collectionVIewA?.reloadData()
        }
    }
    
    func callBackFromAPI() {
        SVProgressHUD.dismiss()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension VIPPartnersReviseVC:  UICollectionViewDelegate, UICollectionViewDataSource {
     @objc func onPhone(_ sender: UIButton){
          // use the tag of button as index
          let data = linkData[sender.tag]
            if let zone = data["phone"] as? String{
                       let trimmed = zone.replacingOccurrences(of: " ", with: "")
                       let phoneURL: URL = URL(string: "telprompt://\(trimmed)")! // Removed white space
                       
                       if UIApplication.shared.canOpenURL(phoneURL) {
                           if #available(iOS 10.0, *) {
                               UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                           } else {
                               UIApplication.shared.openURL(phoneURL)
                           }
                       } else {
                           // Call facility is not available on your device
                       }
                   }
        
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return linkData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionCell", for: indexPath) as! MainCollectionCell
        cell.txtTitle.text = "VIP Partners"
        cell.dedscTitle.text = linkData[indexPath.row]["title"] as? String ?? ""
//        cell.detailDescription.text = linkData[indexPath.row]["description"] as? String ?? ""
       let detailItem = linkData[indexPath.row]["description"] as? String ?? ""
        
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
         cell.webView.loadHTMLString(html, baseURL: nil)
        cell.onPhone.addTarget(self, action: #selector(onPhone(_:)), for: .touchUpInside)
       cell.onPhone.tag = indexPath.row
        if let image =  linkData[indexPath.row]["images"] as? [String] {
               cell.imgArray = image
               cell.collectionVIewA.reloadData()
        }
//        globalIndexPath = indexPath
       
   
//            cell.imgView.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue +  (dataSource[indexPath.row]["image"] as! String))
        //}
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         print(indexPath.row)
         globalIndexPath = indexPath
        if indexPath.row == linkData.count - 1 {
            // do something
            if next_page != nil{
                 SVProgressHUD.show()
                current_page = current_page + 1
                getVipPartners()
            }
        }
    }
}

