//
//  DocumentsListViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 27/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
class DocumentsListViewController: UIViewController,APIsDelegate,UISearchBarDelegate {
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tbl_View: UITableView?
    var name = ""
    var id = "";
    var data = [[String: Any]]();
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
    var next_page:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.addPullToRefresh()
        lblTitle.text = name
        theme()
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
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
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["search": search , "limit": "20","page": "\(current_page)","category_id": id]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_DOCUMENTS.rawValue, viewController: self, params: params) { (response) in
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
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
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
    func theme(){
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        tbl_View?.separatorStyle = .none
        tbl_View?.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
}
extension DocumentsListViewController: UITableViewDataSource, UITableViewDelegate{
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
        let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.name = data[indexPath.row]["name"] as? String ?? ""
        let type = data[indexPath.row]["type"] as? String ?? ""
        if type == "file"{
             vc.url = API_URLS.BASE_URL_DOCUMENTS.rawValue.appending(data[indexPath.row]["file"] as? String ?? "")
        }else  if type == "text"{
            vc.url = data[indexPath.row]["file"] as? String ?? ""
        }else{
             vc.url = API_URLS.BASE_URL_DOCUMENTS.rawValue.appending(data[indexPath.row]["file"] as? String ?? "")
        }
       
        vc.isDoc = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
