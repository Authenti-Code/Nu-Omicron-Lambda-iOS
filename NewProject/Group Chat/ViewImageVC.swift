//
//  ViewImageVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 09/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
class ViewImageVC: UIViewController {
    var image:String?
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//    img.pin_setImage(from: URL(string: image ?? "")!)
        let imageURL = URL(string: image ?? "")!
        img.sd_imageIndicator = SDWebImageActivityIndicator.gray
        img.sd_setImage(with: imageURL)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
