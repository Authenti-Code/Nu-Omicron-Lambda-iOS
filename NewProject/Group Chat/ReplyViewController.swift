//
//  ReplyViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 22/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import Starscream
import Photos
import IQKeyboardManager
import Alamofire
import SVProgressHUD
import SDWebImage
import GrowingTextView
protocol ChangeMessage {
    func onchange(pos: Int, count: Int)
}
class ReplyViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SocketConnectionManagerDelegate,AttachmentText,UITextFieldDelegate,GrowingTextViewDelegate {
    func sendText(str: String) {
        message = str
        updateProfile()
    }
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
       UIView.animate(withDuration: 0.2) {
           self.view.layoutIfNeeded()
       }
    }
    var deligate: ChangeMessage?
    var pos = Int()
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    var imageView : UIImage!
    var dataSource = [[String:Any]]()
    var messageSource = [String:Any]()
    var senderId = ""
    var message = "Hello world"
    var message_type = "text"
    var device_type = "ios"
    var attachment = ""
    var reply_id = 37
    var lastHeight:CGFloat = 0
    var isLoading = false
    var current_page = 1;
    var next_page: String?
    var selectedButton: UIButton!
    @IBOutlet weak var viewPost: UIView!
    @IBOutlet weak var edtPost: UITextField!
    var topSafeArea: CGFloat?
    var bottomSafeArea: CGFloat?
    @IBOutlet weak var bottomViewConstraints: NSLayoutConstraint!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtMessage: GrowingTextView!
    
    var socket: WebSocket = SocketConnectionManager.shared.socket

    func onDataReceive(str: String) {
        let message_data = convertToDictionary(text: str)
        if let id = message_data?["receiver_id"] as? Int{
            if "\(id)" != "0" {
                return
            }
        }
        
        if let id = message_data?["reply_id"] as? Int{
            if "\(id)" == "0" {
                return
            }
        }
        var localMessage = [String : Any]()
        localMessage["id"] = message_data?["id"]
        localMessage["sender_name"] = message_data?["sender_name"]
        localMessage["sender_id"] = message_data?["sender_id"]
        localMessage["sender_image"] = message_data?["sender_image"]
        localMessage["local_message_id"] = message_data?["local_message_id"]
        localMessage["message"] = message_data?["message"]
        localMessage["created_at"] = message_data?["created_at"]
        localMessage["type"] = message_data?["type"]
        localMessage["attachment"] = message_data?["attachment"]
        dataSource.append(localMessage)
        tableView?.reloadData()
        scrollToBottom()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        print(bottomSafeArea ?? 0)
        // safe area values are now available to use
        
    }
    @IBAction func onAttach(_ sender: UIButton) {
        selectedButton = sender
        chooseFromOptions()
    }
    @IBAction func onSend(_ sender: Any) {
        
        message = txtMessage.text ?? ""
               message = message.trimmingCharacters(in: .whitespacesAndNewlines)
               message_type = "text"
               if message.count == 0{
                   txtMessage.text = ""
                 return
               }
       
        var localTime = Int64(Date().timeIntervalSince1970*1000)
        
        let data1 = "{\"sender_id\" :\"\(senderId)\",\"attachment\" :\"\(self.attachment)\",\"receiver_id\":\"\(0)\",\"message\":\"\(message.replacingOccurrences(of: "\n", with: "\\n"))\",\"type\":\"\(message_type)\",\"device_type\":\"\(device_type)\",\"reply_id\":\"\(reply_id)\",\"local_message_id\":\"\(localTime)\"}"
        let data = Data(data1.utf8)
        if socket.isConnected{
            socket.write(data: data)
            txtMessage.text = ""
        }else{
            socket.connect()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketConnectionManager.shared.vc = self
    }
    @IBAction func onBack(_ sender: Any) {
        deligate?.onchange(pos: pos, count: dataSource.count)
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
          txtMessage.minHeight = 25.0
          txtMessage.maxHeight = 100.0
          
          txtMessage.delegate = self
          txtMessage.placeholder = "Text Message..."
          txtMessage.trimWhiteSpaceWhenEndEditing = true
        edtPost.delegate = self
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//        IQKeyboardManager.shared().isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        senderId = UserDefaults.standard.string(forKey: "id") ?? ""
        tableView?.delegate = self
        tableView?.dataSource = self
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        buttonContainer?.layer.cornerRadius = 20
        messageContainer?.layer.cornerRadius = 20
        messageContainer.clipsToBounds = true
        buttonContainer.clipsToBounds = true
//        tableView!.transform = CGAffineTransform(scaleX: 1, y: -1)
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getAllPost();
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            let val = bottomViewConstraints.constant
            print(keyboardSize.height)
            bottomViewConstraints.constant = keyboardSize.height - 1
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomViewConstraints.constant = 0
    }
    func getAllPost() {
        var params = [String:String]()
        params = ["limit": "20","page": "\(current_page)","type": "all","id": "\(reply_id)"]
        API.shared.getData(url: API_ENDPOINTS.GET_CHAT_REPLY_LIST.rawValue, viewController: self, params: params) { (model) in
            print(model)
            let data = model["data"] as! [String : Any]
            
            let replyData = data["reply"] as! [String : Any]
            let localdataSource = replyData["data"] as! [[String : Any]]
            self.next_page = replyData["next_page_url"] as? String
            self.messageSource = data["message"] as! [String : Any]
            if self.dataSource.count == 0{
                self.dataSource.insert(self.messageSource, at: 0)
            }
            self.dataSource = self.dataSource + localdataSource.reversed()
            self.tableView?.reloadData()
            self.scrollToBottom()
            self.isLoading = false
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
                if next_page != nil{
                    current_page = current_page + 1
                    getAllPost()
                }
        }
    }
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.dataSource.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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
    private func chooseFromOptions(){
        let alertViewController = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.checkCameraPermission()
            
        })
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (alert) in
            self.checkGalleryPermission()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alertViewController.popoverPresentationController?.sourceView = (selectedButton as! UIView)
        }
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func updateProfile() {
        //        let params: Parameters = ["name": "abcd", "dob": "1990-09-19","mobile": "8747484"]
        if !socket.isConnected{socket.connect()}
        let imageData = imageView.jpegData(compressionQuality: 0.50)!
        Alamofire.upload(multipartFormData:
            {
                (multipartFormData) in
                multipartFormData.append(imageData, withName: "media", fileName: "file.jpeg", mimeType: "image/*")
        }, to:API_URLS.BASE_URL.rawValue + API_ENDPOINTS.UPLOAD_CHAT_MEDIA.rawValue,headers:Common.getTokenURLHeader())
        { (result) in
            switch result {
            case .success(let upload,_,_ ):
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                upload.responseJSON
                    { response in
                        //print response.result
                        if response.result.value != nil
                        {
                            let dict :NSDictionary = response.result.value! as! NSDictionary
                            let status = dict.value(forKey: "status")as! Bool
                            if status
                            {
                                var localTime = Int64(Date().timeIntervalSince1970*1000)
                               
                                var imagedata = dict.value(forKey: "data") as! [String : Any]
                                self.attachment = imagedata["media"] as! String
                                self.message_type = "attachment"
                                let data1 = "{\"sender_id\" :\"\(self.senderId)\",\"reply_id\":\"\(self.reply_id)\",\"attachment\" :\"\(self.attachment)\",\"receiver_id\":\"\(0)\",\"message\":\"\(self.message)\",\"type\":\"\(self.message_type)\",\"device_type\":\"\(self.device_type)\",\"local_message_id\":\"\(localTime)\"}"
                                print("DATA UPLOAD SUCCESSFULLY")
                                let data = Data(data1.utf8)
                                self.socket.write(data: data)
                                self.txtMessage.text = ""
                            }
                        }
                }
            case .failure(let encodingError):
                break
            }
        }
    }
    private func checkGalleryPermission(){
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.openGallery()
                    
                } else {}
            })
        }else if (photos ==  .authorized){
            //            self.openGallary()
            self.openGallery()
        }
    }
    private func checkCameraPermission(){
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            
            
            self.openCamera()
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    self.openCamera()
                } else {
                    // User rejected
                }
            })
        }
    }
    
    private func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    private func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView = info[.editedImage] as? UIImage
        //        imgUser.image = imageView
        dismiss(animated:true, completion: nil)
//        updateProfile()
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AttachmentVC") as! AttachmentVC
        vc.image = imageView
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }


}

extension ReplyViewController: UITableViewDelegate, UITableViewDataSource{
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        
        let imgView = tapGestureRecognizer.view as! UIImageView
        let idToMove = imgView.tag
        let image: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[idToMove]["attachment"] as? String ?? "")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
        
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func userTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imgView = tapGestureRecognizer.view as! UIImageView
        let idToMove = imgView.tag
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewProfileController") as! ViewProfileController
        vc.id =  "\(dataSource[idToMove]["sender_id"] as? Int ?? 0)"
        if self.senderId != "\(dataSource[idToMove]["sender_id"] as? Int ?? 0)"{
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource[indexPath.row]["type"] as! String == "text" {
            return UITableView.automaticDimension
        } else {
            let font = UIFont.systemFont(ofSize: 13);
            var str: String = (dataSource[indexPath.row]["message"] as! String)
            let heigth = Utility.heightForLabel(text: str, font: UIFont(name: font.fontName, size: 13)!, width: 200)
            //            let heigth = (dataSource[indexPath.row]["message"] as! String).heightWithConstrainedWidth(width: 200, font: UIFont(name: font.fontName, size: 13)!)
            return (240 + heigth)
        }
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row]["type"] as! String != "text" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? AllPostImageCell else{
                return UITableViewCell()
            }
            // Check if the last row number is the same as the last current data element
//            cell.lblDate.text = dataSource[indexPath.row]["created_at"] as! String
            cell.lblDate.text = Utility.convertToDate(str: (dataSource[indexPath.row]["created_at"] as! String)).timeAgoSinceDate()
            cell.selectionStyle = .none
            cell.imgUser?.layer.cornerRadius = 20
            cell.btnView?.layer.cornerRadius = 2.5
            cell.chatContainerview?.layer.cornerRadius = 5.0
            //            cell.lblTime.text = dataSource[indexPath.row]["created_at"] as! String
            cell.lblName.text = dataSource[indexPath.row]["sender_name"] as? String ?? "W’boro Brother"
//            cell.imgPost?.imageFromServerURL(urlString: API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["message"] as? String ?? ""))
//            if let image = dataSource[indexPath.row]["attachment"] as? String{
//                var image1: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["attachment"] as? String ?? "")
//                print(image)
//                cell.imgPost.pin_setImage(from: URL(string: image1)!)
//            }
            if let image1 = dataSource[indexPath.row]["attachment"] as? String{
                //                 cell.imgPost.pin_setImage(from: URL(string: (API_URLS.BASE_URL_MEDIA.rawValue + image1))!)
//                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                cell.imgUser.sd_setImage(with: imageURL)
                cell.imgPost?.sd_setImage(with: URL(string: API_URLS.BASE_URL_MEDIA.rawValue + image1)!) { (image, error, cache, urls) in
                    if (error != nil) {
                        cell.imgPost?.image = UIImage(named: "imgView")
                    } else {
                        cell.imgPost?.image = image
                    }
                }
            }
            if let message = dataSource[indexPath.row]["message"] as? String{
                 cell.lblMessage.text = dataSource[indexPath.row]["message"] as! String
                
            }
           
            cell.imgPost.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            cell.imgPost.isUserInteractionEnabled = true
            cell.imgPost.addGestureRecognizer(tapGestureRecognizer)
//             if let imageData = dataSource[indexPath.row]["sender_image"] as? String {
//                 cell.imgUser?.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? ""))
//            }
            if (dataSource[indexPath.row]["sender_image"] as? String) != nil {
                
                
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? "")
                print(image)
//                cell.imgPost.image =  nil
//                cell.imgUser.pin_setImage(from: URL(string: image)!)
                let imageURL = URL(string: image)!
                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgUser.sd_setImage(with: imageURL)
            }
            if indexPath.row == 0 {
                cell.container?.backgroundColor = UIColor.black
                cell.lblDate.textColor = UIColor.white
                cell.lblName.textColor = UIColor.white
               
            }else{
                cell.container?.backgroundColor = UIColor(red:227/255, green:227/255, blue:227/255, alpha: 1)
                cell.lblDate.textColor = UIColor.black
                cell.lblName.textColor = UIColor.black
                
            }
            let tapGestureRecognizerUser = UITapGestureRecognizer(target: self, action: #selector(userTapped(tapGestureRecognizer:)))
            tapGestureRecognizerUser.numberOfTapsRequired = 1
            cell.imgUser.isUserInteractionEnabled = true
            cell.imgUser.addGestureRecognizer(tapGestureRecognizerUser)
//            if indexPath.row == 0 {
//                cell.chatViewContainer?.backgroundColor = UIColor.black
//            }
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllPostTableCell", for: indexPath) as? AllPostTableCell else{
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.imgChatUser?.layer.cornerRadius = 20
            cell.viewButtonContainer?.layer.cornerRadius = 2.5
            cell.chatViewContainer?.layer.cornerRadius = 5.0
             cell.lblDate.text = Utility.convertToDate(str: (dataSource[indexPath.row]["created_at"] as! String)).timeAgoSinceDate()
//            cell.lblDate.text = dataSource[indexPath.row]["created_at"] as! String
            cell.lblName.text = dataSource[indexPath.row]["sender_name"] as? String ?? "W’boro Brother"
            cell.lblMessage.text = dataSource[indexPath.row]["message"] as! String
            if (dataSource[indexPath.row]["sender_image"] as? String) != nil {
                
                
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? "")
                print(image)
//                cell.imgChatUser?.pin_setImage(from: URL(string: image)!)
                let imageURL = URL(string: image)!
                cell.imgChatUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgChatUser.sd_setImage(with: imageURL)
            }
//            if (dataSource[indexPath.row]["sender_image"] as? String) != nil {
//
//
//                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? "")
//                print(image)
//                cell.imgUser.pin_setImage(from: URL(string: image)!)
//            }
            var type = dataSource[indexPath.row]["message"] as! String
            
            if indexPath.row == 0 {
                cell.chatViewContainer?.backgroundColor = UIColor.black
                cell.lblDate.textColor = UIColor.white
                cell.lblName.textColor = UIColor.white
                cell.lblMessage.textColor = UIColor.white
            }else{
                cell.chatViewContainer?.backgroundColor = UIColor(red:227/255, green:227/255, blue:227/255, alpha: 1)
                cell.lblDate.textColor = UIColor.black
                cell.lblName.textColor = UIColor.black
                cell.lblMessage.textColor = UIColor.black
            }
            let tapGestureRecognizerUser = UITapGestureRecognizer(target: self, action: #selector(userTapped(tapGestureRecognizer:)))
            tapGestureRecognizerUser.numberOfTapsRequired = 1
            cell.imgChatUser.isUserInteractionEnabled = true
            cell.imgChatUser.addGestureRecognizer(tapGestureRecognizerUser)
            return cell
        }
        
    }
    
    
}

