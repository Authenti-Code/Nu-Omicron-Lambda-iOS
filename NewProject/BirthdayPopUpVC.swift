//
//  BirthdayPopUpVC.swift
//  NewProject
//
//  Created by AuthentiCode on 07/01/21.
//  Copyright © 2021 osx. All rights reserved.
//

import UIKit

class BirthdayPopUpVC: UIViewController {

    @IBOutlet weak var oTopLbl: UILabel!
    @IBOutlet weak var oNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserDefaults.standard.value(forKey: "name") as? String
        self.oNameLbl.text = name
        UserDefaults.standard.set("0", forKey: "BirthdayMessage")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissBtnAct(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            UserDefaults.standard.set("0", forKey: "BirthdayMessage")
        })
    }
    
    @IBAction func dismissBtnAct1(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            UserDefaults.standard.set("0", forKey: "BirthdayMessage")
        })
    }
}
