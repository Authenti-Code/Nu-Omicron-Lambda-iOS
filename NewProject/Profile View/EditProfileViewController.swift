//
//  EditProfileViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 27/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import DatePickerDialog
import AVFoundation
import Photos
import Alamofire
import SVProgressHUD
import SDWebImage

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var edtPhone: UITextField!
    @IBOutlet weak var edtWebsite: UITextField!
    var profile_image: String?
    @IBOutlet weak var imgUser: UIImageView!
    var imageView : UIImage!
    
    @IBOutlet weak var edtAlphaId: UITextField!
    @IBOutlet weak var edtState: UITextField!
    @IBOutlet weak var edtCity: UITextField!
    @IBAction func onImagePick(_ sender: UIButton) {
        selectedButton = sender
        chooseFromOptions()
    }
    
    @IBOutlet weak var edtDescription: UITextView!
    
    @IBOutlet weak var lblIdNumber: UILabel!
    @IBOutlet weak var lblLifeTimeNumber: UILabel!
    var selectedButton: UIButton!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var edtName: UITextField!
    
    @IBOutlet weak var countainerView: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    
    @IBOutlet weak var oJobTextField: UITextField!
    @IBOutlet weak var OPlaceTextField: UITextField!
    @IBOutlet weak var oUniversityTextField: UITextField!
    
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var name = "", dob = "", phone = "", city  = "",state = "", website = "",desc = "",alphaid = ""
    
    @IBAction func onQrClick(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onUpdate(_ sender: Any) {
         name = edtName.text ?? ""
         city = edtCity.text ?? ""
         state = edtState.text ?? ""
         phone = edtPhone.text ?? ""
         website = edtWebsite.text ?? ""
         desc = edtDescription.text ?? ""
         alphaid = edtAlphaId.text ?? ""
        if name.count == 0{
            self.showAlert(text: "Please enter name")
            return
        }else if alphaid.count == 0{
            self.showAlert(text: "Please enter alpha id")
            return
        }else{
            if Reachability.isConnectedToNetwork(){
                
            }else{
                showAlert(text: "No Internet Connection")
                return
            }
            SVProgressHUD.show()
            updateProfile()
        }
        
    }
    @IBAction func onDateChange(_ sender: Any) {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.dob = formatter.string(from: dt)
                self.lblDob.text = Utility.formatDate(date: self.dob)
            }
        }
    }
    
    @IBAction func onPhoneChange(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Alert", message: "Edit Phone Number", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.numberPad
            if self.lblPhone.text != "enter phone number."{
                 textField.text = self.lblPhone.text
               
            }
           
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if textField?.text?.count ?? 0 > 0{
                self.lblPhone.text = textField?.text
                self.phone = textField?.text ?? ""
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editView.layer.cornerRadius = editView.frame.size.width/2
        editView.clipsToBounds = true
        edtDescription.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        edtDescription.layer.cornerRadius = 10
        edtDescription.layer.borderWidth = 1.5
        countainerView.layer.masksToBounds = true
        countainerView.layer.cornerRadius = 4
        countainerView.layer.borderColor = #colorLiteral(red: 0.7333333333, green: 0.5529411765, blue: 0.1254901961, alpha: 1)
        countainerView.layer.borderWidth = 1.0
        initProfile()
        getUserDetails()
        self.edtPhone.delegate = self
        // Do any additional setup after loading the view.
    }
    

    func initProfile()  {
        if let id_number = UserDefaults.standard.string(forKey: "id_number")  {
             lblIdNumber.text = "ID No. " + id_number
        }else{
            lblIdNumber.text = ""
        }
        if let life = UserDefaults.standard.string(forKey: "lifetime_number")  {
            let no = "Lifetime No. " + life
            lblLifeTimeNumber.text = no
        }else{
            lblLifeTimeNumber.text = ""
        }
        
        edtCity.text = UserDefaults.standard.string(forKey: "city") ?? ""
        edtState.text = UserDefaults.standard.string(forKey: "state") ?? ""
        edtWebsite.text = UserDefaults.standard.string(forKey: "website") ?? ""
        edtDescription.text = UserDefaults.standard.string(forKey: "description") ?? ""
        edtName.text = UserDefaults.standard.string(forKey: "name") ?? ""
        lblEmail.text = UserDefaults.standard.string(forKey: "email") ?? ""
        lblPhone.text = UserDefaults.standard.string(forKey: "phone") ?? ""
        edtPhone.text = UserDefaults.standard.string(forKey: "phone") ?? ""
        phone = UserDefaults.standard.string(forKey: "phone") ?? ""
        alphaid = UserDefaults.standard.string(forKey: "alpha_id") ?? ""
        edtAlphaId.text = alphaid
        self.oJobTextField.text = UserDefaults.standard.string(forKey: "job_title") ?? ""
        self.OPlaceTextField.text = UserDefaults.standard.string(forKey: "place_of_employment") ?? ""
        self.oUniversityTextField.text = UserDefaults.standard.string(forKey: "university_college_attended") ?? ""
//        lblDob.text = UserDefaults.standard.string(forKey: "dob") ??
        if let  birth = UserDefaults.standard.string(forKey: "dob") {
            dob = birth
            lblDob.text =  Utility.formatDate(date: dob)
            self.lblDob.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }else{
            lblDob.text = "enter date of birth."
            self.lblDob.textColor = #colorLiteral(red: 0.5647058824, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
        }
        
        if let image = UserDefaults.standard.string(forKey: "profile_image"){
            let image1: String = API_URLS.BASE_URL_IMAGES_USER.rawValue + (image as! String)
//            imgUser.pin_setImage(from: URL(string: image1)!)
            let imageURL = URL(string: image1)!
            self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
                       
            self.imgUser.sd_setImage(with: imageURL)
            self.imgUser.layer.masksToBounds = false
//                       self.imgUser.layer.borderColor = UIColor.white.cgColor
                       self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width / 2
                       self.imgUser.clipsToBounds = true
//            imgUser.imageFromServerURL(urlString: API_URLS.BASE_URL_IMAGES_USER.rawValue + image)
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
           params = ["user_id": UserDefaults.standard.string(forKey: "id") ?? "0"]
           API.shared.getData(url: API_ENDPOINTS.GET_USER_DETAILS.rawValue, viewController: self, params: params) { (response) in
               
               let data1 = response["data"] as! [String : Any]
              
               if let id_number = data1["alpha_id"] as? String {
//                   self.lblIdNumber.text = "Alpha Id " + id_number
               }
               if let lifetime_number = data1["lifetime_number"] as? String {
                   self.lblLifeTimeNumber.text = "Lifetime No. " + lifetime_number
               }
              
           }
       }
    
    func updateProfile() {
        let params: Parameters = ["name": name, "dob": dob,"mobile": phone,"city": city,"state":state,"website":website,"alpha_id":alphaid,"job_title":self.oJobTextField.text ?? "","university_college_attended":oUniversityTextField.text ?? "","place_of_employment":OPlaceTextField.text ?? ""]
        
        
        Alamofire.upload(multipartFormData:
            {
                (multipartFormData) in
                if self.imageView != nil{
                    let imageData = self.imageView.jpegData(compressionQuality: 0.50)!
                    multipartFormData.append(imageData, withName: "profile_image", fileName: "file.jpeg", mimeType: "image/*")
                }
                for (key, value) in params
                {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
        }, to:API_URLS.BASE_URL.rawValue + API_ENDPOINTS.UPDATE_USER.rawValue,headers:Common.getTokenURLHeader())
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
                                print(dict)
                                
                            
                             var data = dict.value(forKey: "data") as! [String :Any]
                                var user = data["user"] as! [String :Any]
                                let city = user["city"] as? String
                                let state = user["state"] as? String
                                let website = user["website"] as? String
                                var name1 = user["name"] as! String
                                var dob1 = user["dob"] as? String
                                var phone1 = user["mobile"] as? String
                                var profile_image1 = user["profile_image"] as? String
                                var alpha_id = user["alpha_id"] as? String
                                UserDefaults.standard.set(alpha_id, forKey: "alpha_id")
                                 UserDefaults.standard.set(name1, forKey: "name")
                                UserDefaults.standard.set(dob1, forKey: "dob")
                                UserDefaults.standard.set(self.desc, forKey: "description")
                                UserDefaults.standard.set(phone1, forKey: "phone")
                                UserDefaults.standard.set(city, forKey: "city")
                                UserDefaults.standard.set(state, forKey: "state")
                                UserDefaults.standard.set(website, forKey: "website")
                                UserDefaults.standard.set(profile_image1, forKey: "profile_image")
                                UserDefaults.standard.set(self.oUniversityTextField.text ?? "", forKey: "university_college_attended")
                                UserDefaults.standard.set(self.OPlaceTextField.text ?? "", forKey: "place_of_employment")
                                UserDefaults.standard.set(self.oJobTextField.text ?? "", forKey: "job_title")
                                self.showAlert(text: "Profile updated successfully")
                                self.initProfile()
                                SVProgressHUD.dismiss()
                            }
                        }
                }
            case .failure(let encodingError):
                SVProgressHUD.dismiss()
                break
            }
        }
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
    
    private func checkGalleryPermission(){
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async {
                        self.openGallery()
                    }
                    
                } else {}
            })
        }else if (photos ==  .authorized){
            DispatchQueue.main.async {
                self.openGallery()
            }
        }
    }
    private func checkCameraPermission(){
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            DispatchQueue.main.async {
                self.openCamera()
            }
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                } else {
                    // User rejected
                }
            })
        }
    }
    
    private func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else { return }
        imageView = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView = info[.cropRect] as? UIImage
        imgUser.image = imageView
        dismiss(animated:true, completion: {
        self.moveToImageCropper(image: originalImage)
        })
    }
    @IBAction func onClearName(_ sender: Any) {
        edtName.text = ""
    }
}

extension EditProfileViewController : CropViewControllerDelegate {
    
    private func moveToImageCropper(image: UIImage) {
        let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        cropController.aspectRatioPickerButtonHidden = true
        cropController.aspectRatioLockEnabled = true
        cropController.aspectRatioPreset = .presetSquare
        cropController.modalPresentationStyle = .fullScreen
        self.present(cropController, animated: true, completion: nil)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imgUser.image = image
        imageView = image
//        let compressData = image.jpegData(compressionQuality: 0.5)
//        let compressedImage = UIImage(data: compressData!)
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
extension EditProfileViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
        if self.edtPhone.text == textField.text{
        self.edtPhone.text = textField.text!.toPhoneNumber()
        }
        return true
    }
}
