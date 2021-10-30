//
//  ConnectionHandler.swift
//  NewProject
//
//  Created by osx on 19/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import Alamofire

let backGroundColor = UIColor().getBackgroundColor()
let borderCol       = UIColor().getBorderColor()

class ConnectionHandler: NSObject{
    
    class func jsonPOSTRequest (url: String, parameters: [String : Any], completion: @escaping (Any) -> Void)
    {
    let requestUrl = API_URLS.BASE_URL.rawValue + url
//    let header = Common.getTokenURLHeader()
    Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: nil ).responseJSON { (response:DataResponse<Any>) in
        
        switch(response.result) {
        case .success(_):
            completion(response.result.value!)
            break
        case .failure(_):
            completion(response.result.error!)
            break
        }
        
    }
    
 }
    class func jsonPOSTRequest (url: String, parameters: [String : Any],headers: [String : String], completion: @escaping (Any) -> Void)
    {
        let requestUrl = API_URLS.BASE_URL.rawValue + url
//            let header = Common.getTokenURLHeader()
        print("parms:-",parameters)
        Alamofire.request(requestUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: headers ).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                completion(response.result.value!)
                break
            case .failure(_):
                completion(response.result.error!)
                break
            }
            
        }
        
    }

    class func jsonGETRequest(url: String, completion: @escaping (Any) -> Void)
    {
        var requestUrl = API_URLS.BASE_URL.rawValue + url //base URL
        requestUrl = requestUrl.replacingOccurrences(of: "+", with: "%2B")
        
        let header = Common.getTokenURLHeader()
        Alamofire.request(requestUrl,method: .get,encoding: JSONEncoding.default, headers: header)
            .responseJSON { (response: DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    completion(response.result.value!)
                    
                case .failure(_):
                    print(response.result.error!)
                    completion(response.result.error!)
                    break
                }
        }
    }


}
