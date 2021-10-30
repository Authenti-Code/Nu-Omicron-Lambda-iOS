//
//  QRCodeVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 09/11/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import QRCode
class QRCodeVC: UIViewController {

    @IBOutlet weak var imgQR: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgQR.image = {
            var qrCode = QRCode(UserDefaults.standard.string(forKey: "id") ?? "")!
            qrCode.size = self.imgQR.bounds.size
            qrCode.errorCorrection = .High
            return qrCode.image
        }()
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
