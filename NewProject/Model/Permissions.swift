//
//  Permissions.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import UIKit
class Permissions: NSObject, NSCoding {
    
    var itemID: Int?
    var itemName: String?
    
    init(json: [String: Any])
    {
        self.itemID = json["id"] as? Int
        self.itemName = json["name"] as? String
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.itemID, forKey: "id")
        aCoder.encode(self.itemName, forKey: "name")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.itemID = aDecoder.decodeObject(forKey: "id") as? Int
        self.itemName = aDecoder.decodeObject(forKey: "name") as? String
    }
    
}
