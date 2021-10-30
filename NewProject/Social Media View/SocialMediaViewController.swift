//
//  SocialMediaViewController.swift
//  NewProject
//
//  Created by osx on 23/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SideMenuSwift
import SVProgressHUD
import AVFoundation
import QRCodeReader
import NotificationCenter

import MediaPlayer

class SocialMediaViewController: UIViewController,APIsDelegate,QRCodeReaderViewControllerDelegate {
    //MARK:- Outlets and Variables
    @IBOutlet weak var socialCollectView: UICollectionView?
    
    @IBOutlet weak var chatContainer: UIView!
    @IBOutlet weak var messageIndicator: UIView!
    @IBOutlet weak var indicator: UIView!
    var lblArr = ["DIRECTORY","GROUP CHAT","EVENTS","DOCUMENTS","PAYMENTS","VOTING","SCAN"]
    var imgArr = ["directory-1","group-chat","events-1","documents-1","payments-1","vip-partners"]
    var sideMenu = [MenuItem]()
    var id  = ""
    private let sectionInsets = UIEdgeInsets(top: 10.0,
                                             left: 10.0,
                                             bottom: 10.0,
                                             right: 10.0)
    var hideChat = true
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
     func showAirPlayMenu(){
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let airplayVolume = MPVolumeView(frame: rect)
        airplayVolume.showsVolumeSlider = false
        //player?.allowsExternalPlayback = true
        //player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        self.view.addSubview(airplayVolume)
        for view: UIView in airplayVolume.subviews {
          if let button = view as? UIButton {
            button.sendActions(for: .touchUpInside)
            break
          }
        }
        airplayVolume.removeFromSuperview()
      }
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showAirPlayMenu()
        self.pushViewController()
        
        // Register to receive notification in your class
       // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMessage(_:)), name: NSNotification.Name(rawValue: "notificationName"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.newChat(_:)), name: NSNotification.Name(rawValue: "notificationChat"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        socialCollectView?.delegate   = self
        socialCollectView?.dataSource = self
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        SideMenuController.preferences.basic.menuWidth = screenWidth*0.8
        let permissionArray = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "permissions") as! Data) as! [Permissions]
        for permission in permissionArray {
            for item in MenuHandler.getHomeMenu(){
                if item.itemID == permission.itemID{
                    sideMenu.append(item)
                    if item.itemID == 7{
                        hideChat = false
                    }
                    
                }
            }
        }
//        sideMenu.append(MenuItem(id: -12,name: "VIP PARTNERS", icon: "vip",isPermanent: true))
        if hideChat{
            chatContainer.isHidden = true
            indicator.isHidden = true
        }
        
        

    }
    
    func pushViewController(){
        let birthdaymessage = UserDefaults.standard.value(forKey: "BirthdayMessage") as? String
         if birthdaymessage == "1"{
             let resultController = self.storyboard?.instantiateViewController(withIdentifier: "BirthdayPopUpVCID") as! BirthdayPopUpVC
                 self.navigationController?.definesPresentationContext = true
             //    resultController.delegate = self
                 resultController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                 resultController.modalTransitionStyle = .crossDissolve
                 self.present(resultController, animated: true, completion: nil)
         }
        let Schedulemessages = UserDefaults.standard.value(forKey: "ScheduleMessages") as? String
        let ScheduleMessagesID = UserDefaults.standard.value(forKey: "ScheduleMessagesID") as? Int
        if Schedulemessages == "1"{
            UserDefaults.standard.set("0", forKey: "ScheduleMessages")
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc =  sb.instantiateViewController(withIdentifier: "MessageDetailsViewController") as! MessageDetailsViewController
            if ScheduleMessagesID != nil {
            vc.id = "\(String(describing: ScheduleMessagesID!))"
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func willEnterForeground() {
        print("will enter foreground")
        if Reachability.isConnectedToNetwork(){
            print("connected")
            getData()
        }else{
            showAlert(text: "No Internet Connection")
        }
        hasMessage()
    }
    @IBAction func recentChatClick(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: "noti")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentChatVC") as! RecentChatVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    public func callBackFromAPI(){
        SVProgressHUD.dismiss()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.messageIndicator.layer.cornerRadius =  self.indicator.bounds.size.width/2;
        self.messageIndicator.layer.masksToBounds = true
        if Reachability.isConnectedToNetwork(){
            print("connected")
            getData()
        }else{
            showAlert(text: "No Internet Connection")
        }
        hasMessage()
        
    }
    @objc func newMessage(_ notification: NSNotification)  {
        hasMessage()
    }
    
    @objc func newChat(_ notification: NSNotification)  {
        getData()
    }
    
     func hasMessage()  {
        if let message_noti = UserDefaults.standard.string(forKey: "message_noti"){
          
            if message_noti == "0"{
                 messageIndicator.isHidden = false
            }else{
                messageIndicator.isHidden = true
            }
        }else{
            messageIndicator.isHidden = true
        }
    }
    func getConfiguration(){
        // api.delegate = self
        
        SVProgressHUD.show()
        
        API.shared.getConfiguration(url: API_ENDPOINTS.GET_CONFIGURATION.rawValue, viewController: self) { (response) in
            var data = response["data"] as! [String: Any]
            print(data)
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            if  let url = data["voting"] as? String{
                let vc =  sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                vc.name = "VOTING"
                vc.url = url
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
    }

    @IBAction func sideMenuActionBtn(_ sender: Any) {
         sideMenuController?.revealMenu()
    }
    @IBOutlet weak var messageAlert: UIImageView!
    
    @IBAction func onMessage(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: "message_noti")
        let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageAlertViewController") as! MessageAlertViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func userActionBtn(_ sender: Any) {
     let vc  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getData(){
        // api.delegate = self
        var params = [String:String]()
       
        params = ["search": "" , "limit": "200","page": "\(1)"]
        
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_RECENT_CHAT.rawValue, viewController: self, params: params) { (response) in
            if self.hideChat{
                       self.chatContainer.isHidden = true
                       self.indicator.isHidden = true
                return
                   }
            
            let data1 = response["data"] as! [String : Any]
            
            if  let recentchat =  data1["data"] as? [[String : Any]]{
                let filterdata = recentchat.filter({($0["is_read"] as? String ?? "") == "0"})
                if filterdata.count > 0{
                    self.indicator.isHidden = false
                    self.indicator.layer.cornerRadius =  self.indicator.bounds.size.width/2;
                    self.self.indicator.layer.masksToBounds = true;
                }else{
                    self.indicator.isHidden = true
                }
            }else{
                 self.indicator.isHidden = true
            }
            
            
            
        }
    }
    //API calling
     func getUserDetails(){
         if Reachability.isConnectedToNetwork(){
             
         }else{
             showAlert(text: "No Internet Connection")
             return
         }
         SVProgressHUD.show()
         var params = [String:String]()
         params = ["user_id": id]
         API.shared.getData(url: API_ENDPOINTS.GET_USER_DETAILS.rawValue, viewController: self, params: params) { (response) in
             
             let data1 = response["data"] as! [String : Any]
             var no = ""
             var lifeline = ""
             if let id_number = data1["id_number"] as? String {
                 no = id_number
             }
             if let lifetime_number = data1["lifetime_number"] as? String {
                 lifeline = "Lifetime No. " + lifetime_number
             }
             var name  = data1["name"] as? String
             var email =  data1["email"] as? String
             var image1 = ""
             if let image = data1["profile_image"] as? String{
                 image1 = API_URLS.BASE_URL_IMAGES_USER.rawValue + (image as! String)
                 

             }
            
            let customAlert = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileAlertVC") as! UserProfileAlertVC
            customAlert.providesPresentationContextTransitionStyle = true
            customAlert.definesPresentationContext = true
            customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            customAlert.name = name ?? ""
            customAlert.email = email ?? ""
            customAlert.id_number = no
            customAlert.image = image1
            customAlert.life_number = lifeline
            self.present(customAlert, animated: true, completion: nil)
            
         }
     }
    func chargeDonation()  {
        SVProgressHUD.show()
        var params = [String:String]()
        params = ["user_id": id]
        API.shared.getData(url: API_ENDPOINTS.EVENT_ATTENDED.rawValue, viewController: self, params: params) { (response) in
            SVProgressHUD.dismiss()
            let data1 = response["data"] as! [String : Any]
//            self.showAlert(text: "Success..")
            self.getUserDetails()
            
            
        }
    }

}

extension SocialMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sideMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SocialMediaCollectionVCell else{
            return UICollectionViewCell()
        }
       
        //Inner View
//        cell.directoryView?.layer.cornerRadius = 45.0
//        cell.directoryView?.layer.masksToBounds = true
        cell.homeViewLbl?.text = sideMenu[indexPath.row].itemName
        cell.imgView?.image = UIImage(named: sideMenu[indexPath.row].image!)

       // cell.layer.masksToBounds = false
       // cell.layer.shadowColor = UIColor.gray.cgColor
       // cell.layer.shadowOpacity = 1
       // cell.layer.shadowOffset = .zero
       // cell.layer.cornerRadius = 6.0
        //outer view
   //     cell.outerView?.layer.masksToBounds = true
     //   cell.outerView?.layer.cornerRadius = 6.0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if sideMenu[indexPath.row].itemID == 6{
            guard let directoryController = self.storyboard?.instantiateViewController(withIdentifier: "DirectoryViewController") as? DirectoryViewController else{
                return
            }
            self.navigationController?.pushViewController(directoryController, animated: true)
        }
        if sideMenu[indexPath.row].itemID == 7{
            guard let groupChatController = self.storyboard?.instantiateViewController(withIdentifier: "GroupChatViewController") as? GroupChatViewController else{
                return
            }
            self.navigationController?.pushViewController(groupChatController, animated: true)
        }
        if sideMenu[indexPath.row].itemID == 9{
            guard let docsController = self.storyboard?.instantiateViewController(withIdentifier: "DocumentsViewController") as? DocumentsViewController else{
                return
            }
            self.navigationController?.pushViewController(docsController, animated: true)
        }
        if sideMenu[indexPath.row].itemID == 8{
            guard let eventsController = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController") as? EventsViewController else{
                return
            }
            self.navigationController?.pushViewController(eventsController, animated: true)
        }
        if sideMenu[indexPath.row].itemID == 11{
           getConfiguration()
        }
        if sideMenu[indexPath.row].itemID == 13{
            readerVC.delegate = self
//            id = "21"
//            getUserDetails()
            
            // Or by using the closure pattern
            readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                print(result)
                self.id = result?.value ?? ""
                self.chargeDonation()
            }

            // Presents the readerVC as modal form sheet
            readerVC.modalPresentationStyle = .formSheet

            present(readerVC, animated: true, completion: nil)
        }
        
        if sideMenu[indexPath.row].itemID == 14{
            guard let paymentController = self.storyboard?.instantiateViewController(withIdentifier: "VIPPartnersReviseVC") as? VIPPartnersReviseVC else{
                return
            }
            self.navigationController?.pushViewController(paymentController, animated: true)
        }
        
        if sideMenu[indexPath.row].itemID == 10{
            guard let paymentController = self.storyboard?.instantiateViewController(withIdentifier: "PaymentsViewController") as? PaymentsViewController else{
                return
            }
            self.navigationController?.pushViewController(paymentController, animated: true)
            
        }
    }
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
//        if let cameraName = newCaptureDevice.device.localizedName {
//            print("Switching capture to: \(cameraName)")
//        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension SocialMediaViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (sectionInsets.left * 2 + 30.0)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth/2
        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 20

    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       return 40
    
    }
    
    
}
