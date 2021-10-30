//
//  DocumentsViewController.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage

class DocumentsViewController: UIViewController,APIsDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbl_View: UITableView?
    @IBOutlet weak var imageSlider: UICollectionView!

    var data = [[String: Any]]();
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
    var next_page:String?
    var addsDataSource: [[String:Any]]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.addPullToRefresh()
        theme()
        if Reachability.isConnectedToNetwork(){
            imageSlider.dataSource = self
                 imageSlider.delegate = self
            self.getAdds()
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        getData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("clicked")
        self.searchBar.endEditing(true)
        search =  searchBar.text ?? ""
        
        if search.count > 0{
            self.data.removeAll()
            tbl_View?.reloadData()
            current_page = 1
            getData()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                current_page = current_page + 1
                getData()
            }
        }
    }
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["search": search , "limit": "20","page": "\(current_page)"]

        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_DOCUMENT_CATEGORIES.rawValue, viewController: self, params: params) { (response) in
            print(response)
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.data.removeAll()
                self.tbl_View?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            self.data =   self.data + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tbl_View?.reloadData()
            
        }
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbl_View?.addSubview(refreshControl)
    }
    @objc func refresh() {
        search = ""
        current_page = 1
        getData()
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    func theme(){
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        tbl_View?.separatorStyle = .none
        tbl_View?.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
extension DocumentsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DocumentsTableCell else{
            return UITableViewCell()
        }
        cell.docsLbl?.text = data[indexPath.row]["name"] as! String
        cell.outerView?.layer.shadowColor = UIColor.gray.cgColor
        cell.outerView?.layer.shadowOpacity = 1
        cell.outerView?.layer.shadowOffset = .zero
        cell.outerView?.layer.shadowRadius = 1.2
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc =  sb.instantiateViewController(withIdentifier: "DocumentsListViewController") as! DocumentsListViewController
        vc.name = data[indexPath.row]["name"] as? String ?? ""
        vc.id = "\(data[indexPath.row]["id"] as! Int)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension DocumentsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DocumentPartnerCollectionViewCell", for: indexPath as IndexPath) as! DocumentPartnerCollectionViewCell
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
