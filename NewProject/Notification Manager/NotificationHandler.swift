//
//  NotificationHandler.swift
//  NewProject
//
//  Created by Jatinder Arora on 03/12/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
class  NotificationHandler {
    var id = 0
    var type = ""
     var name = ""
    static let shared: NotificationHandler = {
        let instance = NotificationHandler()
        // Setup code
        return instance
    }()
}
