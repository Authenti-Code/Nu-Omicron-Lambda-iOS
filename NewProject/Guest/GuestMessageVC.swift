//
//  GuestMessageVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 13/03/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD

class GuestMessageVC: UIViewController,APIsDelegate {
    var data = [[String: Any]]();
    var current_page = 1
    var next_page:String?
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var tableview: UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview?.delegate = self
        tableview?.dataSource = self
        tableview?.separatorStyle = .none
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        getData()
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableview?.addSubview(refreshControl)
    }
    @objc func refresh() {
        //        data.removeAll()
        
      
        current_page = 1
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableview?.indexPathForSelectedRow{
            self.tableview?.deselectRow(at: index, animated: true)
        }
    }
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["limit": "20","page": "\(current_page)"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_GUEST_MESSAGE.rawValue, viewController: self, params: params) { (response) in
            print(response)
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.data.removeAll()
                self.tableview?.reloadData()
            }
            let data1 = response["data"] as! [String : Any]
            self.data =   self.data + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tableview?.reloadData()
            
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
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GuestMessageVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MessageAlertCell else{
            return UITableViewCell()
        }
        cell.imageContainer.layer.cornerRadius = cell.imageContainer.frame.size.width / 2
        cell.imageContainer.clipsToBounds = true
        cell.selectionStyle = .none
        
        
        cell.containerView.layer.shadowColor = UIColor.black.cgColor
        cell.containerView.layer.shadowOpacity = 0.2
        cell.containerView.layer.shadowOffset = .zero
        cell.containerView.layer.shadowRadius = 1
        cell.lblTitle.text = data[indexPath.row]["name"] as! String
//        cell.lblDesc.attributedText = (data[indexPath.row]["details"] as! String).htmlToAttributedString
//        cell.lblDesc.datade
        cell.lblDesc.isUserInteractionEnabled = true;
        var dateTime = (data[indexPath.row]["created_at"] as! String).components(separatedBy: " ")
        cell.lblTime.text = Utility.formatDateMessage(date: data[indexPath.row]["created_at"] as! String)
//        cell.lblTimings.text =
        var date = Utility.formatTimeNew(str: data[indexPath.row]["created_at"] as! String)
        print(date)
        cell.lblTimings.text = date
//        cell.containerView.layer.shadowPath = UIBezierPath(rect: cell.containerView.bounds).cgPath
//        cell.containerView.layer.shouldRasterize = true
//        cell.containerView.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
        
        let vc =  sb.instantiateViewController(withIdentifier: "GuestMessageDetailsVC") as! GuestMessageDetailsVC
        vc.data = data[indexPath.row]
        let id = data[indexPath.row]["id"] as! Int
        vc.id = "\(id)"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

