//
//  PaymentsViewController.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage
import Stripe

class PaymentsViewController: UIViewController,APIsDelegate,STPAddCardViewControllerDelegate {
    
  
    
    @IBOutlet weak var tbl_View: UITableView?
    @IBOutlet weak var imageSlider: UICollectionView!

    var lblArr = ["Grand Tax","Chapter Tax","Donations"]
    var refreshControl = UIRefreshControl()
    var dataSource = [[String: Any]]()
    var search = ""
    var stripe_token = ""
    var tax_id = ""
    var current_page = 1
    var next_page:String?
    var addsDataSource: [[String:Any]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        theme()
        API.shared.deligate = self ;
        if Reachability.isConnectedToNetwork(){
            imageSlider.dataSource = self
                 imageSlider.delegate = self
            self.getAdds()
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        getDirectories()
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbl_View?.addSubview(refreshControl)
    }
    func theme(){
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        tbl_View?.separatorStyle = .none
        tbl_View?.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
    @objc func refresh() {
        search = ""
        current_page = 1
        getDirectories()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tbl_View?.indexPathForSelectedRow{
            self.tbl_View?.deselectRow(at: index, animated: true)
        }
    }
    
    func chargeDonation()  {
        var params = [String:String]()
        params = ["id": tax_id,"nonce": stripe_token]
        API.shared.getData(url: API_ENDPOINTS.CHARGE_DONATION.rawValue, viewController: self, params: params) { (response) in
            
            
            let data1 = response["data"] as! [String : Any]
            self.showAlert(text: "Payment Processed Succesfully")
            
        
        }
    }
    //API calling
    func getDirectories(){
        var params = [String:String]()
        params = ["limit": "100","page": "\(current_page)","search": search]
        API.shared.getData(url: API_ENDPOINTS.GET_PAYMENT_LINKS_METHODS.rawValue, viewController: self, params: params) { (response) in
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.dataSource.removeAll()
                self.tbl_View?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            self.dataSource =   self.dataSource + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tbl_View?.reloadData()
        }
    }
    public func callBackFromAPI(){
        
        SVProgressHUD.dismiss()
    }
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleAddPaymentOptionButtonTapped() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
//     func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
//        print("------token is here-------")
//        print(token)
//        stripe_token = token.tokenId;
//        dismiss(animated: true)
//        if stripe_token.count > 0 {
//            chargeDonation()
//        }
//        // call api for payment
//
//
//    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        print("------token is here-------")
//        print(token)
//        stripe_token = token.tokenId;
        dismiss(animated: true)
        if stripe_token.count > 0 {
            chargeDonation()
        }
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext)
    {
        if let card = paymentContext.selectedPaymentOption as? STPCard {
            let token = card.stripeID
            stripe_token = token
            // store token as required
        }
    }
    
}
extension PaymentsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PaymentsTableCell else{
            return UITableViewCell()
        }
        cell.paymentLbl?.text = dataSource[indexPath.row]["name"] as! String
        cell.paymentView?.layer.shadowColor = UIColor.gray.cgColor
        cell.paymentView?.layer.shadowOpacity = 1
        cell.paymentView?.layer.shadowOffset = .zero
        cell.paymentView?.layer.shadowRadius = 1.2

        
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tax_id = "\(dataSource[indexPath.row]["id"] as! Int)"
        var link = dataSource[indexPath.row]["link"] as? String
        guard let url = URL(string: link ?? "") else {
                   return //be safe
               }
               
               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               } else {
                   UIApplication.shared.openURL(url)
               }
//        handleAddPaymentOptionButtonTapped()
    }
    
    
}
extension PaymentsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
//                print( response.result.value!)
                break
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentPartnerCollectionViewCell", for: indexPath as IndexPath) as! PaymentPartnerCollectionViewCell
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
