//
//  MenuHandler.swift
//  NewProject
//
//  Created by Jatinder Arora on 16/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation

class MenuHandler {
    public static func getSideMenu() -> [MenuItem]{
        var homeMenu = [MenuItem]()
        homeMenu.append(MenuItem(id: -4,name: "Welcome", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -5,name: "Contact Office", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -6,name: "Helpful Numbers", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -7,name: "Community Links", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -8,name: "Photos", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -9,name: "Comments", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -10,name: "Gate Access", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: -11,name: "Newsletter", icon: "about",isPermanent: true))
//        homeMenu.append(MenuItem(id: -1,name: "About MU Lambda", icon: "about",isPermanent: true))
        homeMenu.append(MenuItem(id: 1,name: "Message Alert", icon: "alert",isPermanent: false))
        homeMenu.append(MenuItem(id: 2,name: "NOL Social Media", icon: "social",isPermanent: false))
        homeMenu.append(MenuItem(id: 3,name: "Alpha Links", icon: "links",isPermanent: false))
        homeMenu.append(MenuItem(id: 4,name: "News Ticker", icon: "news",isPermanent: false))
        homeMenu.append(MenuItem(id: 5,name: "Contact Us", icon: "torch",isPermanent: false))
        homeMenu.append(MenuItem(id: -2,name: "Settings", icon: "settings",isPermanent: true))
        homeMenu.append(MenuItem(id: -3,name: "Helpdesk", icon: "help",isPermanent: true))
        
        return homeMenu
    }
    
    
    public static func getHomeMenu() -> [MenuItem]{
        var homeMenu = [MenuItem]()
        homeMenu.append(MenuItem(id: 6,name: "DIRECTORY", icon: "directory-1",isPermanent: false))
        homeMenu.append(MenuItem(id: 7,name: "GROUP CHAT", icon: "group-chat",isPermanent: false))
        homeMenu.append(MenuItem(id: 8,name: "EVENTS", icon: "events-1",isPermanent: false))
        homeMenu.append(MenuItem(id: 9,name: "DOCUMENTS", icon: "documents-1",isPermanent: false))
        homeMenu.append(MenuItem(id: 10,name: "PAYMENTS", icon: "payments-1",isPermanent: false))
        homeMenu.append(MenuItem(id: 11,name: "VOTING", icon: "voting1",isPermanent: false))
        homeMenu.append(MenuItem(id: 13,name: "SCAN", icon: "qr-code2",isPermanent: false))
        homeMenu.append(MenuItem(id: 14,name: "VIP Partners", icon: "vip-partners",isPermanent: false))
        
        return homeMenu
    }
    
}
