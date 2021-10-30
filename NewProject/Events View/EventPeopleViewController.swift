//
//  EventPeopleViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class EventPeopleViewController: UIViewController,APIsDelegate {
    var users = [[String:Any]]()
    var id : Int?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        eventAttendList()
        // Do any additional setup after loading the view.
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    func eventAttendList(){
        // api.delegate = self
        var params = [String:String]()
        params = ["event_id": "\(id!)"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.EVENT_ATTEND_LIST.rawValue.appending("?event_id=\(id!)"), viewController: self, params: params) { (response) in
            print(response)
            let data = response["data"] as! [String : Any]
            self.users = data["data"] as! [[String : Any]]
            //            print(data)
            self.tableView.reloadData()
        }
    }
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension EventPeopleViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleGoingTableCell", for: indexPath) as? PeopleGoingTableCell else {
            
            return UITableViewCell()
        }
        if let user = users[indexPath.row]["user"] as? [String:Any]{
            cell.lblName.text = user["name"] as? String ?? ""
            if let userImgUrl = user["profile_image"] as? String {
                let image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (user["profile_image"] as? String ?? "")
                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgUser.sd_setImage(with: imageURL)
                cell.imgUser.layer.cornerRadius =  cell.imgUser.layer.frame.height / 2
            } else {
                cell.imgUser.image = UIImage(named: "user")
            }
        }else{
            cell.lblName.text = "W’boro Brother"
            cell.imgUser.image = UIImage(named: "user")
        }
        return cell
        
    }
    
    
}
