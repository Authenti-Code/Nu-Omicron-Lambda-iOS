//
//  SocketConnectionManager.swift
//  NewProject
//
//  Created by Jatinder Arora on 22/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import Starscream

@objc protocol SocketConnectionManagerDelegate {
    func onDataReceive(str: String)
}

class SocketConnectionManager : WebSocketDelegate {
//    http://31.14.40.72:8081
//    http://31.14.40.72:8092
    var socket = WebSocket(url: URL(string: "ws://31.14.40.72:8088")!)
    var vc: SocketConnectionManagerDelegate?
    static let shared = SocketConnectionManager()
    
    private init() {
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        //        socket.write(string: "hello there!")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        print("Received text: \(text)")
        vc?.onDataReceive(str: text)
        
//        let message_data = convertToDictionary(text: text)
        
//        var localMessage = [String : Any]()
//        localMessage["id"] = message_data?["id"]
//        localMessage["sender_name"] = message_data?["sender_name"]
//        localMessage["sender_id"] = message_data?["sender_name"]
//        localMessage["sender_image"] = message_data?["sender_image"]
//        localMessage["local_message_id"] = message_data?["local_message_id"]
//        localMessage["message"] = message_data?["message"]
//        localMessage["created_at"] = message_data?["created_at"]
//        localMessage["type"] = message_data?["type"]
//        dataSource.insert(localMessage, at: 0)
//        tableView?.reloadData()
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
    func sendMessage(str: String) {
        let data = Data(str.utf8)
        socket.write(data: data)
    }
}
