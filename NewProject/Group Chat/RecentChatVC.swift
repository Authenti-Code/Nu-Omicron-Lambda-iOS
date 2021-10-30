//
//  RecentChatVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 26/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class RecentChatVC: UIViewController,APIsDelegate,SocketConnectionManagerDelegate,OnNewMessage {
    
    func onNewMessage(pos: Int, data: [String : Any]) {
        print(self.data[pos]["message_id"] as! String)
        print(data["message_id"] as! String)
       
        if self.data[pos]["message_id"] as? String != data["message_id"] as? String {
            print("change")
            self.data[pos]["created_at"] = data["created_at"]
            self.data[pos]["message"] = data["message"]
            self.data[pos]["type"] = data["type"]
            let item = self.data[pos]
            self.data.remove(at: pos)
            self.data.insert(item, at: 0)
            tableView.reloadData()
            
            //
        }else{
             print("not change")
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    var data = [[String: Any]]();
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
    var next_page:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPullToRefresh()
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        SVProgressHUD.show()
        theme()
        getData()
       

    }
    override func viewWillAppear(_ animated: Bool) {
        SocketConnectionManager.shared.vc = self
        
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func onDataReceive(str: String) {
        let message_data = convertToDictionary(text: str)
        
        
        if let id = message_data?["receiver_id"] as? Int{
            if "\(id)" == "0" {
                return
            }
        }
        
        
//        var localMessage = [String : Any]()
//        localMessage["id"] = message_data?["id"]
//        localMessage["sender_name"] = message_data?["sender_name"]
//        localMessage["sender_id"] = message_data?["sender_id"]
//        localMessage["sender_image"] = message_data?["sender_image"]
//        localMessage["local_message_id"] = message_data?["local_message_id"]
//        localMessage["message"] = message_data?["message"]
//        localMessage["created_at"] = message_data?["created_at"]
//        localMessage["type"] = message_data?["type"]
//        localMessage["attachment"] = message_data?["attachment"]
//        localMessage["receiver_id"] = message_data?["receiver_id"]
//
//        dataSource.insert(localMessage, at: 0)
        tableView?.reloadData()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                current_page = current_page + 1
                SVProgressHUD.show()
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
        self.data.removeAll()
        params = ["search": search , "limit": "200","page": "\(current_page)"]
        
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_RECENT_CHAT.rawValue, viewController: self, params: params) { (response) in
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.data.removeAll()
                self.tableView?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            print(data1)
            self.data =   self.data + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tableView?.reloadData()
            
        }
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    @objc func refresh() {
        search = ""
        current_page = 1
        getData()
    }
    func theme(){
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
    }
}
extension RecentChatVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return data.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentChatCell", for: indexPath) as? RecentChatCell else{
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
//        cell.imgUser?.layer.cornerRadius = 20
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width / 2
        cell.imgUser.clipsToBounds = true
        print(data[indexPath.row]["is_read"])
        let isRead  = data[indexPath.row]["is_read"] as? String
        if isRead == "0"{
            cell.indicator.isHidden = false
             cell.indicator.layer.cornerRadius =  cell.indicator.bounds.size.width/2;
             cell.indicator.layer.masksToBounds = true;
        }else{
             cell.indicator.isHidden = true
        }
        var id = UserDefaults.standard.string(forKey: "id") ?? ""
        if "\(data[indexPath.row]["receiver_id"] as! Int)" != id{
            if let rname = data[indexPath.row]["receiver_name"] as? String{
                            cell.lblName.text = data[indexPath.row]["receiver_name"] as! String
                       }else{
                           cell.lblName.text = "W’boro Brother"
                       }
            if (data[indexPath.row]["receiver_image"] as? String) != nil {
                
                
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (data[indexPath.row]["receiver_image"] as? String ?? "")
                print(image)
//                cell.imgUser.pin_setImage(from: URL(string: image)!)
                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgUser.sd_setImage(with: imageURL)
            }else{
                cell.imgUser.image = #imageLiteral(resourceName: "user")
            }
        }else{
            cell.lblName.text = data[indexPath.row]["sender_name"] as? String ?? ""
            if (data[indexPath.row]["sender_image"] as? String) != nil {
                
                
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (data[indexPath.row]["sender_image"] as? String ?? "")
                print(image)
                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgUser.sd_setImage(with: imageURL)
//               cell.imgUser.pin_setImage(from: URL(string: image)!)
                
            }else{
                cell.imgUser.image = #imageLiteral(resourceName: "user")
            }
        }
        
        
         if data[indexPath.row]["type"] as! String == "text" {
            cell.lblMessage.text = data[indexPath.row]["message"] as! String
         }else{
            cell.lblMessage.text = "attachment"
        }
        cell.time.text = Utility.convertToDate(str: (data[indexPath.row]["created_at"] as! String)).timeAgoSinceDate()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnetoOneChatVC") as! OnetoOneChatVC
        
        var id = UserDefaults.standard.string(forKey: "id") ?? ""
        if "\(data[indexPath.row]["receiver_id"] as! Int)" != id{
             vc.receiverId = "\(data[indexPath.row]["receiver_id"] as! Int)"
             vc.receiverName = "\(data[indexPath.row]["receiver_name"] as? String ?? "W’boro Brother")"
        }else{
            vc.receiverId = "\(data[indexPath.row]["sender_id"] as! Int)"
            vc.receiverName = "\(data[indexPath.row]["sender_name"] as? String ?? "W’boro Brother")"
        }
       vc.pos = indexPath.row
       vc.delegate = self
       data[indexPath.row]["is_read"] = "1"
       tableView.reloadRows(at: [indexPath], with: .top)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
