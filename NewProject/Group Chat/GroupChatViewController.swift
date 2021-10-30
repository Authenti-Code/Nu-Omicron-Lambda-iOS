//
//  GroupChatViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class GroupChatViewController: UIViewController {
    
    enum child : Int {
        case current    = 0
        case additional = 1
    }
    
    var pageController : GroupchatPageViewController?

    @IBOutlet weak var allPostUnderView: UIView?
    @IBOutlet weak var galleryUnderView: UIView?
    @IBOutlet weak var sendButtonView: UIView?
    @IBOutlet weak var postCommentView: UIView?
    
    //MARK:- View Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButtonView?.layer.cornerRadius = 17.5
        postCommentView?.layer.cornerRadius = 20
        if Reachability.isConnectedToNetwork(){
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
      //  sendButtonView?.layer.masksToBounds = true

    }
    

    @IBAction func allPostActionBtn(_ sender: Any) {
        pageController?.selectTab(.current)
    }
    
    @IBAction func galleryActionBtn(_ sender: Any) {
        pageController?.selectTab(.additional)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        pageController = segue.destination as? GroupchatPageViewController
        pageController?.customDelegate = self
        
    }
    
    @IBAction func backActionBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension GroupChatViewController : updateChatView{
    
    func updateHeader(index: Int) {
        if index == 1{
            allPostUnderView?.backgroundColor = UIColor.black
            galleryUnderView?.backgroundColor = UIColor.clear
            
            return
        }
        
        if index == 2{
            allPostUnderView?.backgroundColor = UIColor.clear
            galleryUnderView?.backgroundColor = UIColor.black
            
            return
        }
    }
    
    
}
