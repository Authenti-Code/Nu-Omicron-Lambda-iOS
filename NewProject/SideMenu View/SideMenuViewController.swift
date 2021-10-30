//
//  SideMenuViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 05/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SideMenuSwift
import SVProgressHUD
import Alamofire
import SDWebImage
class SideMenuViewController: UIViewController,APIsDelegate {
    
    //MARK:- Outlets and Variables
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var menuTableView: UITableView?
    @IBOutlet weak var lblname: UILabel!
    var type = ""
    var id = 0
    let menuList = [
        "About NOL",
        "Message Alert",
        "NOL Social Media",
        "Alpha Links",
        "News Ticker",
        "The TORCH",
        "Settings"
    ]
    
    @IBOutlet weak var viewImageContainer: UIView!
    @IBOutlet var outerview: UIView!
    let iconList = [
        "about",
        "alert",
        "social",
        "links",
        "news",
        "torch",
        "settings"
    ]
    var sideMenu = [MenuItem]()
    let viewControllerList = [
        AboutViewController.self,
        MessageAlertViewController.self,
        SocialMediaViewController.self,
        AlphaLinksViewController.self,
        NewsTickerViewController.self,
        NewsTickerViewController.self,
        SettingsViewController.self
        ]
    
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    //MARK:- View Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.deligate = self
        menuTableView?.backgroundColor = UIColor.clear
        menuTableView?.delegate = self
        menuTableView?.dataSource = self
        menuTableView?.separatorStyle = .none
    let permissionArray = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "permissions") as! Data) as! [Permissions]
        
//        print("\(permissionArray[0].itemName!)\(permissionArray[1].itemName!)")
//           sideMenu.append(MenuItem(id: -4,name: "Welcome", icon: "about",isPermanent: true))
//        sideMenu.append(MenuItem(id: -5,name: "Contact Office", icon: "about",isPermanent: true))
//         sideMenu.append(MenuItem(id: -6,name: "Helpful Numbers", icon: "about",isPermanent: true))
//         sideMenu.append(MenuItem(id: -7,name: "Community Links", icon: "about",isPermanent: true))
//        sideMenu.append(MenuItem(id: -8,name: "Photos", icon: "about",isPermanent: true))
//                sideMenu.append(MenuItem(id: -9,name: "Comments", icon: "about",isPermanent: true))
//        sideMenu.append(MenuItem(id: -10,name: "Gate Access", icon: "about",isPermanent: true))
//        sideMenu.append(MenuItem(id: -11,name: "Newsletter", icon: "about",isPermanent: true))
      sideMenu.append(MenuItem(id: -1,name: "About NOL", icon: "about",isPermanent: true))
        for permission in permissionArray {
            for item in MenuHandler.getSideMenu(){
                if item.itemID == permission.itemID{
                    sideMenu.append(item)
                }
            }
        }
        sideMenu.append(MenuItem(id: -2,name: "Settings", icon: "settings",isPermanent: true))
        sideMenu.append(MenuItem(id: -3,name: "Helpdesk", icon: "help",isPermanent: true))
        
        viewImageContainer.layer.masksToBounds = true
        viewImageContainer.layer.cornerRadius = 16
        viewImageContainer.layer.borderColor = #colorLiteral(red: 0.7333333333, green: 0.5529411765, blue: 0.1254901961, alpha: 1)
        viewImageContainer.layer.borderWidth = 1.0
        
        imgUser.layer.masksToBounds = true
        imgUser.layer.cornerRadius = 16
        
        
        lblname.text = UserDefaults.standard.string(forKey: "name") ?? ""
        lblEmail.text = UserDefaults.standard.string(forKey: "email") ?? ""
        if NotificationHandler.shared.type.count != 0{
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            if NotificationHandler.shared.type == "Event"{
                let vc =  sb.instantiateViewController(withIdentifier: "EventsDetailsViewController") as! EventsDetailsViewController
                
                //        vc.data = data[indexPath.row]
                vc.id = NotificationHandler.shared.id
                NotificationHandler.shared.type = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }else if NotificationHandler.shared.type == "News"{
                let vc =  sb.instantiateViewController(withIdentifier: "NewsTickerDetailsViewController") as! NewsTickerDetailsViewController
                
                //        vc.data = data[indexPath.row]
                vc.id = "\(NotificationHandler.shared.id)"
                NotificationHandler.shared.type = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }else if NotificationHandler.shared.type == "Message"{
                let vc =  sb.instantiateViewController(withIdentifier: "MessageDetailsViewController") as! MessageDetailsViewController
                
                //        vc.data = data[indexPath.row]
                vc.id = "\(NotificationHandler.shared.id)"
                NotificationHandler.shared.type = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if NotificationHandler.shared.type == "Chat"{
                let vc =  sb.instantiateViewController(withIdentifier: "OnetoOneChatVC") as! OnetoOneChatVC
                
                //        vc.data = data[indexPath.row]
                vc.receiverId = "\(NotificationHandler.shared.id)"
                vc.receiverName = NotificationHandler.shared.name
                NotificationHandler.shared.type = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }else if NotificationHandler.shared.type == "Reply"{
                let vc =  sb.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
                
                //        vc.data = data[indexPath.row]
                vc.reply_id = NotificationHandler.shared.id
//                vc.receiverName = NotificationHandler.shared.name
                NotificationHandler.shared.type = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if NotificationHandler.shared.type == "Document"{
               
                
                getDocument(str: "\(NotificationHandler.shared.id)")
            }
           
            
        }
        
    }
    
    func getDocument(str: String){
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        var params = [String:String]()
        params = ["id": str]
        SVProgressHUD.show()
        API.shared.getData(url: API_ENDPOINTS.GET_DOCUMENT_DETAIL.rawValue, viewController: self, params: params) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
            SVProgressHUD.dismiss()
            NotificationHandler.shared.type = ""
            // Do here
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.name = data["name"] as? String ?? ""
            let type = data["type"] as? String ?? ""
            if type == "file"{
                vc.url = API_URLS.BASE_URL_DOCUMENTS.rawValue.appending(data["file"] as? String ?? "")
            }else  if type == "text"{
                vc.url = data["file"] as? String ?? ""
            }else{
                vc.url = API_URLS.BASE_URL_DOCUMENTS.rawValue.appending(data["file"] as? String ?? "")
            }
            
            vc.isDoc = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblname.text = UserDefaults.standard.string(forKey: "name") ?? ""
        if let image = UserDefaults.standard.string(forKey: "profile_image"){
//            imgUser.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)
//            if let image = data["image"] as? String{
                let imageURL = URL(string: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)!
                self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgUser.sd_setImage(with: imageURL)
//            }
        }
         navigationController?.setNavigationBarHidden(true, animated: animated)
        if let index = self.menuTableView?.indexPathForSelectedRow{
            self.menuTableView?.deselectRow(at: index, animated: true)
        }
    }
}

extension SideMenuViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as? MenuTableViewCell else{
            return UITableViewCell()
        }
        cell.lblItem.text = sideMenu[indexPath.row].itemName
        cell.imgImage.image = UIImage(named: (sideMenu[indexPath.row].image!))
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.5529411765, blue: 0.1254901961, alpha: 1)
        cell.selectedBackgroundView = view
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        sideMenuController?.hideMenu()
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        var vc : UIViewController?
        switch sideMenu[indexPath.row].itemID {
        case -1:
            guard let socialVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? PrivacyPolicyViewController else{
                return
            }
            socialVC.code = 0; self.navigationController?.pushViewController(socialVC, animated: true)
            return
        case 1:
            vc =  sb.instantiateViewController(withIdentifier: "MessageAlertViewController") as! MessageAlertViewController
        case 2:
            vc =  sb.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        case 3:
            vc =  sb.instantiateViewController(withIdentifier: "AlphaLinksViewController") as! AlphaLinksViewController
        case 4:
            vc =  sb.instantiateViewController(withIdentifier: "NewsTickerViewController") as! NewsTickerViewController
        case 5:
            if Reachability.isConnectedToNetwork(){
                
            }else{
                showAlert(text: "No Internet Connection")
                return
            }
            let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
            vc.userComing = true
            self.navigationController?.pushViewController(vc, animated: true)
//          getConfiguration()
            
            // get the url First
            
//           let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
//            vc.name = "THE TORCH"
//            vc.url = "https://www.lipsum.com"
//           self.navigationController?.pushViewController(vc, animated: true)
            return
        case -2:
            vc =  sb.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        case -4:
               vc =  sb.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        case -5:
               vc =  sb.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        case -6:
               vc =  sb.instantiateViewController(withIdentifier: "HelpfulNumbersViewController") as! HelpfulNumbersViewController
        case -7:
                vc =  sb.instantiateViewController(withIdentifier: "CommunityLinksViewController") as! CommunityLinksViewController
        case -8:
                vc =  sb.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
            
        case -9:
                       vc =  sb.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
                   
        case -11:
                vc =  sb.instantiateViewController(withIdentifier: "NewsLetterViewController") as! NewsLetterViewController
        case -10:
//                let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
//                              vc.name = "GATE ACCESS"
//                vc.url = "https://gateaccess.net/login.aspx"
//                              self.navigationController?.pushViewController(vc, animated: true)
            return
        case -3:
           getHelpLine()
            return
        default:
             sideMenuController?.hideMenu()
            return
        }
        
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    func getHelpLine(){
            
            var params = [String:String]()
            Alamofire.request("https://apa1906.app/api/configuration", method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
                    
                    switch(response.result) {
                    case .success(_):
                       print( )
                       if let response = response.result.value! as? [String : Any] {
                            print(response)
                        if let data = response["data"] as? [String:Any]{
                            let helpline = data["helpline"] as? String
                            let sb = UIStoryboard.init(name: "Main", bundle: nil)
                            let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                                          vc.name = "Helpdesk"
                            vc.url = (helpline ?? "")
                                          self.navigationController?.pushViewController(vc, animated: true)
                        }
                       }
                        break
                    case .failure(_):
        //                print( response.result.value!)
                        break
                    }
                    
                }
            
    }
    func getConfiguration(){
        // api.delegate = self
        
        SVProgressHUD.show()
        
        API.shared.getConfiguration(url: API_ENDPOINTS.GET_CONFIGURATION.rawValue, viewController: self) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            if  let url = data["torch"] as? String{
                let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                vc.name = "Contact Us"
                vc.url = url
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
    }
}
