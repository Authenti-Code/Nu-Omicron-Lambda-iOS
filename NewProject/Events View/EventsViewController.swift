//
//  EventsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 11/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage

class EventsViewController: UIViewController {
    
    enum child : Int {
        case current    = 0
        case additional = 1
    }
    
    var pageController : EventsPageViewController?
    
    @IBOutlet weak var upcomingUnderView: UIView?
    @IBOutlet weak var eventUnderView: UIView?
    @IBOutlet weak var imageSlider: UICollectionView!

    var addsDataSource: [[String:Any]]?

    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork(){
            imageSlider.dataSource = self
                 imageSlider.delegate = self
            self.getAdds()
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
    }
    
    @IBAction func upcomingActionBtn(_ sender: Any) {
        pageController?.selectTab(.current)
    }
    
    @IBAction func pastActionBtn(_ sender: Any) {
        pageController?.selectTab(.additional)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        pageController = segue.destination as? EventsPageViewController
        pageController?.customDelegate = self
    }
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventsViewController : updateView{
    
    func updateHeader(index: Int) {
        if index == 1{
            upcomingUnderView?.backgroundColor = UIColor.black
            eventUnderView?.backgroundColor = UIColor.clear
            
            return
        }
        
        if index == 2{
            upcomingUnderView?.backgroundColor = UIColor.clear
            eventUnderView?.backgroundColor = UIColor.black
            
            return
        }
    }
    
}

extension EventsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func getAdds() {
        var params = [String:String]()
        params = ["key": "3p2ddt8bb3plmhuafvsqrzhrp0ptei7r"]; Alamofire.request("https://apa1906.app/api/adds", method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
               print( )
               if let response = response.result.value! as? [String : Any] {
                    print(response)
                if let adds = response["data"] as? [[String: Any]]{
                    self.addsDataSource = adds
                   self.imageSlider.reloadData()
                }
               }
                break
            case .failure(_):
//                print( response.result.value!)
                break
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventPartnerCollectionViewCell", for: indexPath as IndexPath) as! EventPartnerCollectionViewCell
            let image: String = "https://apa1906.app/uploads/adds/" + (addsDataSource?[indexPath.row]["image"] as? String ?? "")
            print(image)
//            cell.image.pin_setImage(from: URL(string: image)!)
            let imageURL = URL(string: image)!
            cell.image.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.image.sd_setImage(with: imageURL)
//        var image: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["attachment"] as? String ?? "")
       
//        cell.imgPhoto.imageFromServerURL(urlString: API_URLS.BASE_URL_MEDIA.rawValue +  (dataSource[indexPath.row]["message"] as! String))
//        var user = users[indexPath.row]["user"] as! [String:Any]
//        cell.lblName.text = user["name"] as! String
        return cell
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 2;
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
        
        return addsDataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
      
        if let  image = addsDataSource?[indexPath.row]["image"] as? String{
            
          openLink(str: addsDataSource?[indexPath.row]["url"] as! String)
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          return CGSize(width: 80, height: 80)
      }
    
    func openLink(str: String) {
        guard let url = URL(string: str) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    
}
