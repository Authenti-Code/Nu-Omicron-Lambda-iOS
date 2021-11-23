//
//  CommentsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage
class CommentsViewController: UIViewController,APIsDelegate,UITextViewDelegate {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var txtContactNo: UITextField!
    @IBOutlet weak var txtEMail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imageSlider: UICollectionView!

    var userComing : Bool = false
    var varUrlName = ""
    var addsDataSource: [[String:Any]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageSlider.dataSource = self
             imageSlider.delegate = self
        self.getAdds()
         API.shared.deligate = self
        btnSubmit?.layer.cornerRadius = 25.0
        btnSubmit?.clipsToBounds = true
        let color = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        txtMessage.layer.borderColor = color
        txtMessage.layer.borderWidth = 0.5
        txtMessage.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
        txtMessage.text = "Enter Message"
        txtMessage.textColor = UIColor.lightGray
        txtMessage.delegate = self
    }
    func textViewDidEndEditing(_ textView: UITextView) {

        if txtMessage.text == "" {

            txtMessage.text = "Enter Message"
            txtMessage.textColor = UIColor.lightGray
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {

        if txtMessage.textColor == UIColor.lightGray {
            txtMessage.text = ""
            txtMessage.textColor = UIColor.black
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func callBackFromAPI(){
           SVProgressHUD.dismiss()
       }
   
    @IBAction func onSubmit(_ sender: Any) {
        
        if txtName.text?.count == 0{
            showAlert(text: "Please enter Name")
            return
        }else if txtEMail.text?.count == 0{
            showAlert(text: "Please enter Email")
            return
        }else if txtContactNo.text?.count == 0{
            showAlert(text: "Please enter Phone")
            return
        }else if txtMessage.text?.count == 0{
            showAlert(text: "Please enter Message")
            return
        }else{
            if Reachability.isConnectedToNetwork(){
                             
                          }else{
                              showAlert(text: "No Internet Connection")
                              return
                          }
                          SVProgressHUD.show()
                          var params = [String:String]()
                          params = ["name":txtName?.text ?? "",
                              "email":txtEMail?.text ?? "",
                              "phone":txtContactNo?.text ?? "",
                              "message":txtMessage?.text ?? ""
                               ]
            
            if userComing == true{
                self.varUrlName = API_ENDPOINTS.USER_CONTACT_STORE.rawValue
            } else {
                self.varUrlName = API_ENDPOINTS.CONTACT_STORE.rawValue
            }
            
                          API.shared.createAccount(url: self.varUrlName, params: params, viewController: self) { (respo) in
                              print(respo)
                              var refreshAlert = UIAlertController(title: "Success", message: "Message has been posted", preferredStyle: UIAlertController.Style.alert)
                              
                              refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                 self.navigationController?.popViewController(animated: true)
                              }))
                              
                              
                              self.present(refreshAlert, animated: true, completion: nil)
                          }
        }
       
    }
    
}

extension CommentsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func getAdds() {
        var params = [String:String]()
//        kjcebd3zvlzm2orhubovqhhrvvbycgca
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
//                print( response.result.value!)
                break
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentPartnerCollectionViewCell", for: indexPath as IndexPath) as! CommentPartnerCollectionViewCell
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
