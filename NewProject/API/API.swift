//
//  API.swift
//  NewProject
//
//  Created by osx on 19/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import UIKit
@objc protocol APIsDelegate {
    func callBackFromAPI()
}


class API: NSObject{

    var deligate : APIsDelegate?
    
    static let shared = API()
    override private init(){}
    
    func createAccount(url: String, params : [String:Any],viewController:UIViewController, completion: @escaping ([String:Any]) -> Void){
        
        // let header = CommonMethods.getTokenURLHeader()
        ConnectionHandler.jsonPOSTRequest(url: url, parameters: params) { (result:Any) in
            
            self.deligate?.callBackFromAPI()
            if ((result as? [String:Any]) != nil) {
                
                let response = result as! [String : Any]
                if (response["status"] as? Int ?? 0) == 1
                {       
                    _ = response["message"] as? String ?? ""
                    do{
                        completion(response)
                    } catch let err {
                        print("Failed to Serialize the json data due to \(err)")
                    }
                } else {
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
            }
        }
    }
    func forgotPassword(url: String, params : [String:Any],viewController:UIViewController, completion: @escaping ([String:Any]) -> Void){
        
        // let header = CommonMethods.getTokenURLHeader()
        ConnectionHandler.jsonPOSTRequest(url: url, parameters: params) { (result:Any) in

            self.deligate?.callBackFromAPI()
            if ((result as? [String:Any]) != nil) {

                let response = result as! [String : Any]
                if (response["status"] as? Int ?? 0) == 1
                {
                    let message = response["message"] as? String ?? ""
                    
                    do{
                        completion(response)
                        
                    }catch
                        let err{
                            print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                    
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
            }
        }
    }
    func loginUser(url: String,viewController:UIViewController, params : [String : Any], completion: @escaping ([String
            : Any]) -> Void){

        // let header = CommonMethods.getTokenURLHeader()
        ConnectionHandler.jsonPOSTRequest(url: url, parameters: params) { (result:Any) in
            self.deligate?.callBackFromAPI()
            
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                   
                    do{

                        completion(response)
                        
                        
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                    
                    
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
            }
        }
    }
    func resetPassword(url: String,viewController:UIViewController, params : [String : Any], completion: @escaping ([String
        : Any]) -> Void){
        
        let header = Common.getTokenURLHeader()
        
        ConnectionHandler.jsonPOSTRequest(url: url, parameters: params,headers: header) { (result:Any) in
            self.deligate?.callBackFromAPI()
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                    
                    do{
                        
                        completion(response)
                        
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                    
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
            }
        }
    }
    func getData(url: String,viewController:UIViewController, params : [String : Any], completion: @escaping ([String
        : Any]) -> Void){
        
         let header = Common.getTokenURLHeader()
        print("URL:->",url)
        ConnectionHandler.jsonPOSTRequest(url: url, parameters: params,headers: header) { (result:Any) in
            self.deligate?.callBackFromAPI()
            
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                    
                    do{
                        
                        completion(response)
                        
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                    
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
            }
        }
    }
    func getSocialLinks(url: String,viewController:UIViewController, completion: @escaping ([String: Any]) -> Void){
        self.deligate?.callBackFromAPI()
        ConnectionHandler.jsonGETRequest(url: url) { (result) in
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                    let data = response["data"] as? [String:Any] ?? [:]
                    do{
                        //                        let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        //                        let arrActivity = try JSONDecoder().decode([DirectoryModel].self, from: json)
                        completion(response)
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")
                    
                }
            }
            else {
                viewController.showAlert(text: "Server Error")
                
            }
        }
        
    }
    func getConfiguration(url: String,viewController:UIViewController, completion: @escaping ([String: Any]) -> Void){
        self.deligate?.callBackFromAPI()
        ConnectionHandler.jsonGETRequest(url: url) { (result) in
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                    let data = response["data"] as? [String:Any] ?? [:]
                    do{
//                        let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//                        let arrActivity = try JSONDecoder().decode([DirectoryModel].self, from: json)
                        completion(response)
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
        }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")

                }
            }
            else {
                viewController.showAlert(text: "Server Error")

            }
        }
    
     }
    func getAlphaLinks(url: String,viewController:UIViewController, completion: @escaping ([String:Any]) -> Void){
        self.deligate?.callBackFromAPI()
        ConnectionHandler.jsonGETRequest(url: url) { (result) in
            if ((result as? [String : Any]) != nil) {
                
                let response = result as! [String : Any]
                print("the responseeeeeee\(response)")
                if (response["status"] as? Int ?? 0) == 1
                {
                    let data = response["data"] as? [String:Any] ?? [:]
                    do{
                    
                    completion(response)
                    }catch let err{
                        print("Failed to Serialize the json data due to \(err)")
                    }
                }
                else{
                    let error = response["error"] as? [String:Any]
                    let error_message = error!["error_message"] as? [String:Any]
                    let message = error_message!["message"] as? [String]
                    let alert = message?[0]
                    viewController.showAlert(text: alert ?? "Server Error...")

                }
            }
            else {
                viewController.showAlert(text: "Server Error")

            }
        }
        
    }
    
    
    
    
    
}

