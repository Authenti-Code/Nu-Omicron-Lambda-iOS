//
//  ContactsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
class ContactsViewController: UIViewController ,APIsDelegate,UISearchBarDelegate {
    //MARK:- Outlets and Variables
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbl_View: UITableView?
    
    var arr1 = ["Mu Lambda","Mu Lambda","Mu Lambda","Mu Lambda"]
    var arr2 = ["Washington, DC","Washington, DC","Washington, DC","Washington, DC"]
    var imgArr = ["user","user-2","user-3","user-5"]
    var refreshControl = UIRefreshControl()
    var dataSource = [[String: Any]]()
    var search = ""
    var current_page = 1
    var next_page:String?
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPullToRefresh()
        searchBar.delegate = self
//        searchBar.showsCancelButton = true
        API.shared.deligate = self ;
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        tbl_View?.separatorStyle = .none
       
        if Reachability.isConnectedToNetwork(){
            print("connected")
             SVProgressHUD.show()
             getDirectories()
        }else{
            showAlert(text: "No Internet Connection")
        }
       
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbl_View?.addSubview(refreshControl)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
          search =  searchBar.text ?? ""
            self.dataSource.removeAll()
            tbl_View?.reloadData()
            current_page = 1
            getDirectories()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        print("clicked")
//        self.searchBar.endEditing(true)
        search =  searchBar.text ?? ""
        
        //        if search.count > 0{
        self.dataSource.removeAll()
        tbl_View?.reloadData()
        current_page = 1
        getDirectories()
        //        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("clicked")
        self.searchBar.endEditing(true)
//        search =  searchBar.text ?? ""
//
////        if search.count > 0{
//            self.dataSource.removeAll()
//            tbl_View?.reloadData()
//            current_page = 1
//            getDirectories()
////        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                current_page = current_page + 1
                getDirectories()
            }
        }
    }
    @objc func refresh() {
        search = ""
        current_page = 1
        getDirectories()
    }

    public func callBackFromAPI(){
        
        SVProgressHUD.dismiss()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tbl_View?.indexPathForSelectedRow{
            self.tbl_View?.deselectRow(at: index, animated: true)
        }
    }
   
   
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //API calling
    func getDirectories(){
        var params = [String:String]()
        params = ["limit": "20","page": "\(current_page)","search": search]
        API.shared.getData(url: API_ENDPOINTS.GET_DIRECTORY.rawValue, viewController: self, params: params) { (response) in
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
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DirectoryTableViewCell else{
            return UITableViewCell()
        }
        cell.nameLbl.text = dataSource[indexPath.row]["name"] as! String
        if let location = dataSource[indexPath.row]["state"] as? String{
            cell.placeLbl.text = dataSource[indexPath.row]["state"] as! String
        }
        if let image =  dataSource[indexPath.row]["image"] as? String{
            cell.imgView.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue +  (dataSource[indexPath.row]["image"] as! String))
        }
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
       
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
       
        var vc  =  sb.instantiateViewController(withIdentifier: "DirectoryDetailsViewController") as! DirectoryDetailsViewController
        vc.data = self.dataSource[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
   
    
}
