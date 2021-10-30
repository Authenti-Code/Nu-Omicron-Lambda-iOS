//
//  InitialVC.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/02/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
class InitialVC: UIViewController {

    @IBOutlet weak var btnGuest: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnGuest?.layer.cornerRadius = 25.0
        btnGuest?.clipsToBounds = true
        
        btnLogin?.layer.cornerRadius = 25.0
        btnLogin?.clipsToBounds = true
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onGuestClick(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: "is_guest")
        signUP()
    }
    
    func signUP()  {
        if Reachability.isConnectedToNetwork(){
                  
               }else{
                   showAlert(text: "No Internet Connection")
                   return
               }
               SVProgressHUD.show()
               var params = [String:String]()
               params = [
                   "device_type": "ios",
                   "device_token": UserDefaults.standard.string(forKey: "device_token") ?? "NO_DEVICE_TOKEN_FOUND","device_id":"\(String(describing: UIDevice.current.identifierForVendor!.uuidString)))"
                    ]
               API.shared.createAccount(url: API_ENDPOINTS.CREATE_GUEST_ACCOUNT.rawValue, params: params, viewController: self) { (respo) in
                   print(respo)
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                          self.navigationController?.pushViewController(vc, animated: true)
               }
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
