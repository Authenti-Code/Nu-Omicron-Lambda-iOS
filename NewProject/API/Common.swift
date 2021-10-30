//
//  Common.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import UIKit


class Common{

static func getTokenURLHeader() -> [String:String] {
    return [
//            "Content-Type":  "application/x-www-form-urlencoded",
            "Authorization": "Bearer ".appending(UserDefaults.standard.value(forKey: "token") as? String ?? "")]
     }
    static func getAddsHeader() -> [String:String] {
        return [
            //            "Content-Type":  "application/x-www-form-urlencoded",
            "key": "3p2ddt8bb3plmhuafvsqrzhrp0ptei7r"]
        
    }
}



extension UIColor{
    func getBackgroundColor() -> UIColor{
    return UIColor(red: 187/255, green: 141/255, blue: 32/255, alpha: 1.0)
  }
    func getBorderColor()-> UIColor{
        return UIColor(red: 185/255, green: 156/255, blue: 57/255, alpha: 0.3)
    }
}

extension UIViewController{
    func showAlert(text:String){
        let alert = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
