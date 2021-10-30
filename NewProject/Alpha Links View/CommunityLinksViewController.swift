//
//  CommunityLinksViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommunityLinksViewController: UIViewController,APIsDelegate,UISearchBarDelegate {
    //MARK:- Outlets and Variables
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tbl_View: UITableView?
    var linkData = [[String: Any]]()
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
     var next_page:String?
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.addPullToRefresh()
        theme()
        API.shared.deligate = self
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        getAlphaLinks()

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("clicked")
        self.searchBar.endEditing(true)
        search =  searchBar.text ?? ""
        
        if search.count > 0{
            self.linkData.removeAll()
            tbl_View?.reloadData()
            current_page = 1
//            SVProgressHUD.show()
            getAlphaLinks()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tbl_View?.indexPathForSelectedRow{
            self.tbl_View?.deselectRow(at: index, animated: true)
        }
    }
    func theme(){
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        tbl_View?.separatorStyle = .none
        tbl_View?.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                current_page = current_page + 1
                getAlphaLinks()
            }
        }
    }
    func getAlphaLinks(){
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["search": search , "limit": "20","page": "\(current_page)"]
        API.shared.getData(url: API_ENDPOINTS.GET_ALPHA_LINKS.rawValue, viewController: self, params: params) { (response) in
            print(response)
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.linkData.removeAll()
                self.tbl_View?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            self.linkData =   self.linkData + (data1["data"] as! [[String : Any]])
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
        getAlphaLinks()
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    
    
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CommunityLinksViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if linkData.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return linkData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AlphaLinksTableCell else{
            return UITableViewCell()
        }
        cell.nameLbl.text  =  "Community Link #" + "\(indexPath.row)"
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
        
        let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.name = linkData[indexPath.row]["name"] as? String ?? ""
        vc.url = linkData[indexPath.row]["link"] as? String ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
