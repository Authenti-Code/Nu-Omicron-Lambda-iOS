//
//  DirectoryModel.swift
//  NewProject
//
//  Created by osx on 23/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation

struct DirectoryModel:Codable {
    var id:Int?
    var created_at:String?
    var updated_at:String?
    var name:String?
    var description:String?
    var phone:String?
    var dob: String?
    var image : String?
    var website : String?
    var location:String?
    
}
