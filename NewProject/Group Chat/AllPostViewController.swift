//
//  AllPostViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import Starscream
import Photos
import Alamofire
import PINRemoteImage
import SDWebImage
import IQKeyboardManager
import GrowingTextView

class AllPostViewController: UIViewController,WebSocketDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SocketConnectionManagerDelegate,ChangeMessage,AttachmentText ,UITextFieldDelegate,GrowingTextViewDelegate{
  
    func textViewDidEndEditing(_ textView: UITextView) {
          self.view.endEditing(true)
    }
    
func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
   UIView.animate(withDuration: 0.2) {
       self.view.layoutIfNeeded()
   }
}
    func sendText(str: String) {
        message = str
        updateProfile()
    }
    
    func onchange(pos: Int, count: Int) {
        print(pos)
        print(count)
        var count1 = 0
        if count > 0 {
            count1 = count - 1
        }
        dataSource[pos]["reply_count"] = count1
        let indexPath = IndexPath(item: pos, section: 0)
        tableView?.reloadRows(at: [indexPath], with: .top)
    }
    
    func onDataReceive(str: String) {
        let message_data = convertToDictionary(text: str)
        
        if let id = message_data?["receiver_id"] as? Int{
            if "\(id)" != "0" {
                return
            }
        }
        
        if let id = message_data?["reply_id"] as? Int{
            if "\(id)" != "0" {
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
        localMessage["receiver_id"] = message_data?["receiver_id"]
        dataSource.insert(localMessage, at: 0)
        tableView?.reloadData()
    }
    
    @IBOutlet weak var messageContainer: UIView!
    
    @IBOutlet weak var txtMessage: GrowingTextView!
    @IBOutlet weak var buttonContainer: UIView!
    var imageView : UIImage!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var edtMessage: UITextField!
    var dataSource = [[String:Any]]()
    var senderId = ""
    var message = "Hello world"
    var attachment = ""
    var message_type = "text"
    var device_type = "ios"
    var lastHeight:CGFloat = 0
    var isLoading = false
    var current_page = 1;
    var next_page: String?
    @IBOutlet weak var tableView: UITableView?
//    var socket = WebSocket(url: URL(string: "http://192.168.0.107:8080")!)
    var socket: WebSocket = SocketConnectionManager.shared.socket
    var selectedButton: UIButton!
    
    //MARK:- View Life-Cycle
    @IBOutlet weak var bottomViewConstraints: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        txtMessage.minHeight = 25.0
        txtMessage.maxHeight = 100.0
        edtMessage.delegate = self
        txtMessage.delegate = self
        txtMessage.placeholder = "Text Message..."
        txtMessage.trimWhiteSpaceWhenEndEditing = true
//        IQKeyboardManager.shared().isEnableAutoToolbar = false
//        IQKeyboardManager.shared().isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        senderId = UserDefaults.standard.string(forKey: "id") ?? ""
        tableView?.delegate = self
        tableView?.dataSource = self
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView!.transform = CGAffineTransform(scaleX: 1, y: -1)
//        tableView?.rowHeight = UITableView.automaticDimension
//        socket.delegate = self
        buttonContainer?.layer.cornerRadius = 20
        messageContainer?.layer.cornerRadius = 20
        messageContainer.clipsToBounds = true
        buttonContainer.clipsToBounds = true
//        socket.connect()
        // Set automatic dimensions for row height
        // Swift 4.2 onwards
//        tableView?.rowHeight = UITableView.automaticDimension
//        tableView?.estimatedRowHeight = UITableView.automaticDimension
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getAllPost();

    }
    
    func getAllPost() {
        var params = [String:String]()
        params = ["limit": "20","page": "\(current_page)","type": "all"]
        API.shared.getData(url: API_ENDPOINTS.GET_CHAT_LIST.rawValue, viewController: self, params: params) { (model) in
            print(model)
            let data = model["data"] as! [String : Any]
            self.next_page = data["next_page_url"] as? String
            let localdataSource = data["data"] as! [[String : Any]]
            self.dataSource = self.dataSource + localdataSource
            self.tableView?.reloadData()
            self.isLoading = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        SocketConnectionManager.shared.vc = self
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            bottomViewConstraints.constant = keyboardSize.height - 32
            bottomViewConstraints.constant = keyboardSize.height 
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomViewConstraints.constant = 0
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if !isLoading {
                isLoading = true
                if next_page != nil{
                    current_page = current_page + 1
                    getAllPost()
                }
                
            }
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    @objc func buttonView(sender: UIButton){
        print(sender.tag)
        let vc1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        vc1.reply_id = dataSource[sender.tag]["id"] as! Int
        vc1.pos = sender.tag
        vc1.deligate = self
        self.navigationController?.pushViewController(vc1, animated:     true)
    }
    // MARK: Websocket Delegate Methods.
    
    @IBAction func onSend(_ sender: Any) {
        message = txtMessage.text ?? ""
        message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        message_type = "text"
        if message.count == 0{
            txtMessage.text = ""
          return
        }
        var localTime = Int64(Date().timeIntervalSince1970*1000)
        
        let data1 = "{\"sender_id\" :\"\(senderId)\",\"attachment\" :\"\(self.attachment)\",\"receiver_id\":\"\(0)\",\"message\":\"\(message.replacingOccurrences(of: "\n", with: "\\n"))\",\"type\":\"\(message_type)\",\"device_type\":\"\(device_type)\",\"local_message_id\":\"\(localTime)\"}"
        
        
        let data = Data(data1.utf8)
        if socket.isConnected{
            socket.write(data: data)
            txtMessage.text = ""
        }else{
            socket.connect()
        }
    }
    
    @IBAction func onAttach(_ sender: UIButton) {
        selectedButton = sender
        chooseFromOptions()
    }
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
//        socket.write(string: "hello there!")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        print("Received text: \(text)")
        let message_data = convertToDictionary(text: text)
        
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
            dataSource.insert(localMessage, at: 0)
            tableView?.reloadData()
        
    }
    
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
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
    // MARK: Write Text Action
    
    @IBAction func writeText(_ sender: UIBarButtonItem) {
        socket.write(string: "hello there!")
        let string = "[{\"form_id\":3465,\"canonical_name\":\"df_SAWERQ\",\"form_name\":\"Activity 4 with Images\",\"form_desc\":null}]"
        let data = Data(string.utf8)
        socket.write(data: data)
    }
    
    // MARK: Disconnect Action
    
    @IBAction func disconnect(_ sender: UIBarButtonItem) {
        if socket.isConnected {
            sender.title = "Connect"
            socket.disconnect()
        } else {
            sender.title = "Disconnect"
            socket.connect()
        }
    }
    class func instance()->AllPostViewController?{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AllPostViewController") as? AllPostViewController
        
        return controller
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
          if !socket.isConnected{socket.connect()}
//        let params: Parameters = ["name": "abcd", "dob": "1990-09-19","mobile": "8747484"]
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
                                 let data1 = "{\"sender_id\" :\"\(self.senderId)\",\"attachment\" :\"\(self.attachment)\",\"receiver_id\":\"\(0)\",\"message\":\"\(self.message)\",\"type\":\"\(self.message_type)\",\"device_type\":\"\(self.device_type)\",\"local_message_id\":\"\(localTime)\"}"
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
        vc.text = self.txtMessage.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension AllPostViewController: UITableViewDelegate, UITableViewDataSource{
    // method to run when imageview is tapped
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
            
            if let name = dataSource[idToMove]["sender_name"] as? String{
                self.navigationController?.pushViewController(vc, animated: true)
            }
         
        }
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource[indexPath.row]["type"] as! String == "text" {
            return UITableView.automaticDimension
        } else {

           let cell = tableView.cellForRow(at: indexPath) as? AllPostImageCell
            let font = UIFont.systemFont(ofSize: 13);
            var str: String = (dataSource[indexPath.row]["message"] as! String)
            let heigth = Utility.heightForLabel(text: str, font: UIFont(name: font.fontName, size: 13)!, width: cell?.lblMessage.frame.width ?? 250)
//            let heigth = (dataSource[indexPath.row]["message"] as! String).heightWithConstrainedWidth(width: 200, font: UIFont(name: font.fontName, size: 13)!)
            return (275 + heigth)
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row]["type"] as! String != "text" {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? AllPostImageCell else{
                return UITableViewCell()
            }
             // Check if the last row number is the same as the last current data element
            cell.selectionStyle = .none
            cell.imgUser?.layer.cornerRadius = 20
            cell.btnView?.layer.cornerRadius = 2.5
//            cell.chatViewContainer?.layer.cornerRadius = 5.0
//            cell.lblTime.text = dataSource[indexPath.row]["created_at"] as! String
            cell.lblName.text = dataSource[indexPath.row]["sender_name"] as? String ?? "W’boro Brother"
//            var message: String = (API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["message"] as? String ?? ""))
//            print(image)
            var labelW = cell.lblMessage.intrinsicContentSize.width
            print(labelW)
            if let image1 = dataSource[indexPath.row]["attachment"] as? String{
//                 cell.imgPost.pin_setImage(from: URL(string: (API_URLS.BASE_URL_MEDIA.rawValue + image1))!)
                    
//                let imageURL = URL(string: image)!
                cell.imgPost.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                cell.imgUser.sd_setImage(with: imageURL)
                cell.imgPost?.sd_setImage(with: URL(string: API_URLS.BASE_URL_MEDIA.rawValue + image1)!) { (image, error, cache, urls) in
                    if (error != nil) {
                    cell.imgPost?.image = UIImage(named: "imgView")
                    } else {
                    cell.imgPost?.image = image
                        let actualWidth = cell.imgPost!.frame.width
                        print(actualWidth)
//                        dataSource[indexPath.row]["height"] = 400
                        var width: CGFloat = image?.size.width ?? 250
                        var localwidth: CGFloat  = cell.imgPost?.frame.size.width ?? 250
//
//                       var ratio: CGFloat = width / localwidth
//                        cell.imgPost?.frame.size.height = ((image?.size.height)! * ratio)
//                      cell.imgPost?.frame.width
//                    image?.size.height
                        
                    }
                }
            }
           
            cell.imgPost.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            cell.imgPost.isUserInteractionEnabled = true
            cell.imgPost.addGestureRecognizer(tapGestureRecognizer)
            
            if (dataSource[indexPath.row]["sender_image"] as? String) != nil {
                
                
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? "")
                print(image)
//                cell.imgPost.image =  nil
//                cell.imgUser.pin_setImage(from: URL(string: image)!)
                 cell.imgUser.pin_setImage(from: URL(string: image)!)
                
//                let imageURL = URL(string: image)!
//                cell.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                cell.imgUser.sd_setImage(with: imageURL)
                
            }else{
                 cell.imgUser.image = #imageLiteral(resourceName: "user")
            }
            if let count = dataSource[indexPath.row]["reply_count"] as? Int{
                cell.lblReply.text = "\(dataSource[indexPath.row]["reply_count"] as! Int)" + " reply"
            }else{
                 cell.lblReply.text = "0" + " reply"
            }
            
            if let message = dataSource[indexPath.row]["message"] as? String{
                cell.lblMessage.text = message
            }
            cell.lblDate.text = Utility.convertToDate(str: (dataSource[indexPath.row]["created_at"] as! String)).timeAgoSinceDate1()
//            cell.lblDate.text = dataSource[indexPath.row]["created_at"] as! String
            cell.btnView.tag = indexPath.row
            cell.btnView.addTarget(self, action: #selector(buttonView), for: .touchUpInside)
            cell.imgUser.tag = indexPath.row
            let tapGestureRecognizerUser = UITapGestureRecognizer(target: self, action: #selector(userTapped(tapGestureRecognizer:)))
            tapGestureRecognizerUser.numberOfTapsRequired = 1
            cell.imgUser.isUserInteractionEnabled = true
            cell.imgUser.addGestureRecognizer(tapGestureRecognizerUser)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.chatContainerview?.layer.cornerRadius = 5.0
           
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllPostTableCell", for: indexPath) as? AllPostTableCell else{
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.newImage?.layer.cornerRadius = 20
            cell.viewButtonContainer?.layer.cornerRadius = 2.5
            cell.chatViewContainer?.layer.cornerRadius = 5.0
//            cell.lblDate.text = dataSource[indexPath.row]["created_at"] as! String
           
             cell.lblDate.text = Utility.convertToDate(str: (dataSource[indexPath.row]["created_at"] as! String)).timeAgoSinceDate1()
            cell.lblName.text = dataSource[indexPath.row]["sender_name"] as? String ?? "W’boro Brother"
            cell.lblMessage.text = dataSource[indexPath.row]["message"] as! String
           
//            print(heigth)
            if (dataSource[indexPath.row]["sender_image"] as? String) != nil {
                var image: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (dataSource[indexPath.row]["sender_image"] as? String ?? "")
                print(image)
                cell.newImage.pin_setImage(from: URL(string: image)!)
//
//                cell.imageView?.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "user"))
//                cell.imgView?.clipsToBounds = true
//                SDWebImageManager.shared.loadImage(with:URL(string: image), options: [], progress: nil, completed: { (image, data, error, _, _, _) in
//                    DispatchQueue.main.async {
//                        if let error = error {
//                            print("error: \(error)")
//
//                        } else {
//                            if image != nil {
//                                cell.newImage?.image = image
//                                cell.newImage?.clipsToBounds = true
//                            } else {
//                                    cell.newImage.image = #imageLiteral(resourceName: "user")
//                            }
//                        }
//                    }
//                })
                
            }else{
                cell.newImage.image = #imageLiteral(resourceName: "user")
            }
            if let count = dataSource[indexPath.row]["reply_count"] as? Int{
                cell.lblReply.text = "\(dataSource[indexPath.row]["reply_count"] as! Int)" + " reply"
            }else{
                cell.lblReply.text = "0" + " reply"
            }
           
            cell.btnView.tag = indexPath.row
            cell.btnView.addTarget(self, action: #selector(buttonView), for: .touchUpInside)
            var type = dataSource[indexPath.row]["message"] as! String
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.newImage.tag = indexPath.row
            let tapGestureRecognizerUser = UITapGestureRecognizer(target: self, action: #selector(userTapped(tapGestureRecognizer:)))
            tapGestureRecognizerUser.numberOfTapsRequired = 1
            cell.newImage.isUserInteractionEnabled = true
            cell.newImage.addGestureRecognizer(tapGestureRecognizerUser)
            // Check if the last row number is the same as the last current data element
            
            return cell
        }
        
    }
    
    
}
