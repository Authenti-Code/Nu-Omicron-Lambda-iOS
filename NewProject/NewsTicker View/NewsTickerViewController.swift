//
//  NewsTickerViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 06/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class NewsTickerViewController: UIViewController,APIsDelegate {
    var data = [[String: Any]]();
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
    var next_page:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPullToRefresh()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 1
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
        tableView?.addSubview(refreshControl)
    }
    @objc func refresh() {
//        data.removeAll()
    
        search = ""
        current_page = 1
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView?.indexPathForSelectedRow{
            self.tableView?.deselectRow(at: index, animated: true)
        }
    }
    func getData(){
        // api.delegate = self
        var params = [String:String]()
        params = ["limit": "20","page": "\(current_page)"]
        
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_NEWS.rawValue, viewController: self, params: params) { (response) in
            print(response)
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.data.removeAll()
                self.tableView?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            self.data =   self.data + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tableView?.reloadData()
            
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
    @IBAction func onback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @objc func detailsClicked(sender:UIButton) {
        
        let buttonRow = sender.tag
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
        
        let vc =  sb.instantiateViewController(withIdentifier: "NewsTickerDetailsViewController") as! NewsTickerDetailsViewController
        vc.data = data[buttonRow]
        var id = data[buttonRow]["id"] as! Int
        vc.id = "\(id)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func shareClicked(sender:UIButton) {
    
        if let myWebsite = NSURL(string: "https://mulambda.apa1906.app/news-pdf/" + "\(data[sender.tag]["id"] as! Int)") {
            let objectsToShare = ["News", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    
    }
    

}
extension NewsTickerViewController: UITableViewDelegate, UITableViewDataSource{
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewsTickerCell else{
            return UITableViewCell()
        }
        cell.profileContainer.layer.masksToBounds = true
        cell.profileContainer.layer.cornerRadius = 16
        cell.profileContainer.layer.borderColor = #colorLiteral(red: 0.7333333333, green: 0.5529411765, blue: 0.1254901961, alpha: 1)
        cell.profileContainer.layer.borderWidth = 1.0
        
        if let image1 = data[indexPath.row]["image"] as? String{
            var image: String = API_URLS.BASE_URL_IMAGES_NEWS.rawValue + (data[indexPath.row]["image"] as! String)
                  print(image)
                  
                  let imageURL = URL(string: image)!
                  cell.imgPost.sd_imageIndicator = SDWebImageActivityIndicator.gray
                  cell.imgPost.sd_setImage(with: imageURL)
        }
      
//        cell.imgPost.pin_setImage(from: URL(string: image)!)
        
//        cell.imgPost?.imageFromServerURL(urlString: )
        cell.lblDate.text = Utility.formatDate(date: data[indexPath.row]["date"] as! String)
        cell.lblTitle.text = data[indexPath.row]["name"] as! String
//        let from = data[indexPath.row]["from_time"] as! String
//        let to = data[indexPath.row]["to_time"] as! String
//        var time = Utility.formatTime(str: from)  + " - " + Utility.formatTime(str: to)
//        cell.lblTime.text = time
        cell.lblTime.isHidden = true
        cell.btnDetails.tag = indexPath.row
        cell.btnDetails.addTarget(self, action: #selector(detailsClicked(sender:)), for: UIControl.Event.touchDown)
        cell.btnShare.addTarget(self, action: #selector(shareClicked(sender:)), for: UIControl.Event.touchDown)
        //        cell.containerView.layer.shadowPath = UIBezierPath(rect: cell.containerView.bounds).cgPath
        //        cell.containerView.layer.shouldRasterize = true
        //        cell.containerView.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
        
        let vc =  sb.instantiateViewController(withIdentifier: "NewsTickerDetailsViewController") as! NewsTickerDetailsViewController
        vc.data = data[indexPath.row]
        var id = data[indexPath.row]["id"] as! Int
        vc.id = "\(id)"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

