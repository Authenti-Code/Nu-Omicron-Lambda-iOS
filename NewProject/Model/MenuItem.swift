//
//  MenuItem.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
class  MenuItem: NSObject {
    var itemID: Int?
    var itemName: String?
    var image: String?
    var isPermanent: Bool
    init(id: Int,name: String, icon: String, isPermanent: Bool)
    {
        self.itemID = id
        self.itemName = name
        self.image = icon
        self.isPermanent = isPermanent
    }
}
