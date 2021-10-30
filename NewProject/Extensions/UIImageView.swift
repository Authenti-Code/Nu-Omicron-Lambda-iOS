//
//  UIImageView.swift
//  NewProject
//
//  Created by Jatinder Arora on 14/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import UIKit
extension UIImageView{
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil { return }
            
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}
