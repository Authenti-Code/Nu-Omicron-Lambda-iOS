//
//  GuestVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/02/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class GuestVC: UIViewController,APIsDelegate {
    var linkData = [[String: Any]]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var vw: UIView!
    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
          self.navigationController?.isNavigationBarHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
vw.layer.shadowColor = UIColor.gray.cgColor
             vw.layer.shadowOpacity = 1
             vw.layer.shadowOffset = .zero
        let cellWidth : CGFloat = collectionView.frame.size.width / 2.2
              let cellheight : CGFloat = cellWidth
        let cellSize = CGSize(width: cellWidth , height:cellWidth)
              
              let layout = UICollectionViewFlowLayout()
              layout.scrollDirection = .vertical //.horizontal
              layout.itemSize = cellSize
              layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
              layout.minimumLineSpacing = 20.0
              layout.minimumInteritemSpacing = 1.0
              collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
        API.shared.deligate = self
               if Reachability.isConnectedToNetwork(){
                   
               }else{
                   showAlert(text: "No Internet Connection")
                   return
               }
               SVProgressHUD.show()
               getAlphaLinks()
        if NotificationHandler.shared.type.count != 0{
                   let sb = UIStoryboard.init(name: "Main", bundle: nil)
                   if NotificationHandler.shared.type == "Guest_Message"{
                       let vc =  sb.instantiateViewController(withIdentifier: "GuestMessageDetailsVC") as! GuestMessageDetailsVC
                       
                       //        vc.data = data[indexPath.row]
                       vc.id =  "\(NotificationHandler.shared.id)"
                       NotificationHandler.shared.type = ""
                       self.navigationController?.pushViewController(vc, animated: true)
                   }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onMessage(_ sender: Any) {
        let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuestMessageVC") as! GuestMessageVC
               self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onLogin(_ sender: Any) {
        let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
               self.navigationController?.setViewControllers([vc], animated: true)
    }
    @IBAction func onContact(_ sender: Any) {
//        let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func callBackFromAPI(){
           SVProgressHUD.dismiss()
       }
       
    
    func getAlphaLinks(){
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["search": "" , "limit": "100","page": "1"]
        API.shared.getData(url: API_ENDPOINTS.GET_GUEST_LINKS.rawValue, viewController: self, params: params) { (response) in
            print(response)
            let data1 = response["data"] as! [String : Any]
            self.linkData.append(data1)
            self.linkData.append(data1)
            self.linkData =   self.linkData + (data1["data"] as! [[String : Any]])
            
            self.collectionView.reloadData()
        }
    }
}
extension GuestVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = linkData.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SocialMediaCollectionVCell else{
            return UICollectionViewCell()
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowOffset = .zero
        cell.layer.cornerRadius = 6.0
       
        //outer view
        cell.outerView?.layer.masksToBounds = true
        cell.outerView?.layer.cornerRadius = 6.0

        if indexPath.row == 0{
        cell.homeViewLbl?.text = "VIP Partners"
        cell.imgView?.image = UIImage(named: "vip-partners")
        }else if indexPath.row == 1 {
        cell.homeViewLbl?.text = "Contact Us"
        cell.imgView?.image = UIImage(named: "phone-contact")
        } else {
        cell.directoryView?.layer.cornerRadius = 45.0
        cell.directoryView?.layer.masksToBounds = true
//        if linkData.count + 1 > indexPath.row {
        cell.homeViewLbl?.text = linkData[indexPath.row]["name"] as? String
        let image = API_URLS.BASE_URL_GUEST_IMAGE.rawValue + (linkData[indexPath.row]["media"] as? String ?? "512")
       print(image)
//            cell.imgPhoto.pin_setImage(from: URL(string: image)!)
       let imageURL = URL(string: image)!
       cell.imgView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
       cell.imgView?.sd_setImage(with: imageURL)
//        }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let sb = UIStoryboard.init(name: "Main", bundle: nil)
        if indexPath.row == 0{
            guard let paymentController = self.storyboard?.instantiateViewController(withIdentifier: "VIPPartnersReviseVC") as? VIPPartnersReviseVC else{
                return
            }
            self.navigationController?.pushViewController(paymentController, animated: true)
        } else if indexPath.row == 1{
            let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
            vc.userComing = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
             
             let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
             vc.name = linkData[indexPath.row]["name"] as? String ?? ""
             vc.url = linkData[indexPath.row]["link"] as? String ?? ""
             self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.size.width / 2.1), height: 150)
    }

    }
