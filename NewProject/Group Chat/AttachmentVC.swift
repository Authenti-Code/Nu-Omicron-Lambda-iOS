//
//  AttachmentVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 26/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import IQKeyboardManager
import GrowingTextView
protocol AttachmentText {
    func sendText(str: String);
}
class AttachmentVC: UIViewController ,GrowingTextViewDelegate,UITextFieldDelegate{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
       UIView.animate(withDuration: 0.2) {
           self.view.layoutIfNeeded()
       }
    }
    @IBOutlet weak var bottomViewConstraints: NSLayoutConstraint!

    var delegate: AttachmentText?
    var image:UIImage?
    var text : String?
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var sendContainer: UIView!
    @IBOutlet weak var onSend: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
    
    @IBOutlet weak var edtMessage: GrowingTextView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSend(_ sender: Any) {
        if self.edtMessage.text == "" {
            print("abc")
            delegate?.sendText(str: "")
        }
        delegate?.sendText(str: self.edtMessage.text!)
    
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
           if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
               bottomViewConstraints.constant = keyboardSize.height - 32
           }
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }
       @objc func keyboardWillHide(notification: NSNotification) {
           bottomViewConstraints.constant = 0
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared().isEnableAutoToolbar = true
               IQKeyboardManager.shared().isEnabled = true
        imgPost.image = image
        sendContainer?.layer.cornerRadius = 20
        messageContainer?.layer.cornerRadius = 20
        messageContainer.clipsToBounds = true
        sendContainer.clipsToBounds = true
        automaticallyAdjustsScrollViewInsets = false
        edtMessage.minHeight = 25.0
        edtMessage.maxHeight = 100.0
        self.txtMessage.delegate = self
        edtMessage.delegate = self
        edtMessage.placeholder = "Text Message..."
        edtMessage.trimWhiteSpaceWhenEndEditing = true
        edtMessage.text = text
    }
}
