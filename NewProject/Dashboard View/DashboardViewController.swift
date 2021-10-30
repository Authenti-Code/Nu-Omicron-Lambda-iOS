//
//  DashboardViewController.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import Alamofire

class DashboardViewController: UIViewController,APIsDelegate {
    func callBackFromAPI() {
        SVProgressHUD.dismiss()
    }
    
    var dataSource = [[String:Any]]()
    @IBOutlet weak var collectView: UICollectionView!
    @IBOutlet weak var imageSlider: UICollectionView!
    
    var lblArr = ["FACEBOOK","TWITTER","LINKED IN","INSTAGRAM"]
    var imgArr = ["facebook","twitter","linkedin","instagram"]
    var addsDataSource: [[String:Any]]?
    
    private let sectionInsets = UIEdgeInsets(top: 15.0,left: 20.0,bottom: 50.0,right: 20.0)
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        collectView.delegate = self
        collectView.dataSource = self
        if Reachability.isConnectedToNetwork(){
            imageSlider.dataSource = self
            imageSlider.delegate = self
            getAdds()
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getSoial()
    }
    func getSoial() {
        SVProgressHUD.show()
        API.shared.getSocialLinks(url: API_ENDPOINTS.GET_SOCIAL.rawValue, viewController: self) { (response) in
            self.dataSource = response["data"] as! [[String: Any]]
            //            print(data)
            self.collectView.reloadData()
        }
    }
}
extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageSlider == collectionView {
            return addsDataSource?.count ?? 0
        } else {
            return dataSource.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.imageSlider == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardPartnerCollectionViewCell", for: indexPath as IndexPath) as! DashBoardPartnerCollectionViewCell
            let image: String = "https://apa1906.app/uploads/adds/" + (addsDataSource?[indexPath.row]["image"] as? String ?? "")
            //            cell.image.pin_setImage(from: URL(string: image)!)
            let imageURL = URL(string: image)!
            cell.image.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.image.sd_setImage(with: imageURL)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DashboardCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            //Inner View
            cell.outerView?.layer.cornerRadius = 45.0
            cell.outerView?.layer.masksToBounds = true
            cell.homeViewLbl?.text = dataSource[indexPath.row]["name"] as! String
            if let image = dataSource[indexPath.row]["icon"] as? String {
                //            cell.imgView?.pin_setImage(from: URL(string: API_URLS.BASE_URL_SOCIAL_LINK.rawValue + image))
                let imageURL = URL(string: API_URLS.BASE_URL_SOCIAL_LINK.rawValue + image)!
                print(imageURL)
                cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView.sd_setImage(with: imageURL)
            }
            
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = .zero
            cell.layer.cornerRadius = 6.0
            //outer view
            cell.directoryView?.layer.masksToBounds = true
            cell.directoryView?.layer.cornerRadius = 6.0
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.imageSlider == collectionView {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
            if let  image = addsDataSource?[indexPath.row]["image"] as? String{
                openLink(str: addsDataSource?[indexPath.row]["url"] as! String)
            }
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.name = dataSource[indexPath.row]["name"] as! String
            vc.url = dataSource[indexPath.row]["link"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension DashboardViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.imageSlider == collectionView {
            return CGSize(width: 70, height: 70)
        } else {
            let paddingSpace = (sectionInsets.left * 2 + 30.0)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth/2
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
}

extension DashboardViewController  {
    func getAdds() {
        var params = [String:String]()
        params = ["key": "vtqxkzkt5n3kubbjha7uy2l1pc296uqs"]; Alamofire.request("https://apa1906.app/api/adds", method: .post, parameters: params, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
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
                //print( response.result.value!)
                break
            }
        }
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 2;
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1;
    }
    //UICollectionViewDatasource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
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
