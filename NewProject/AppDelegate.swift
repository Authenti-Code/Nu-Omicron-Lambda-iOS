//
//  AppDelegate.swift
//  NewProject
//
//  Created by osx on 22/08/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import CoreData
import SideMenuSwift
//import Firebase
import UserNotifications
import Stripe
import Alamofire
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate {
    
    var window: UIWindow?
    //    pk_test_BmkdFXRa1UI9WgLqBxc4rsSR00jHWwy3tP
    
    func getRoles(){
        var params = [String:String]()
        params = ["user_id": UserDefaults.standard.string(forKey: "id") ?? "0"]
        let header = Common.getTokenURLHeader()
        Alamofire.request( API_URLS.BASE_URL.rawValue +  API_ENDPOINTS.GET_USER_DETAILS.rawValue, method: .post, parameters: params, encoding: JSONEncoding.default,headers: header ).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let response = response.result.value! as? [String : Any] {
                    print(response)
                    if let data = response["data"] as? [String:Any]{
                        //                              var user = data["user"] as! [String :Any]
                        let role = data["role"] as! [String :Any]
                        let permission = role["permission"] as! [[String :Any]]
                        var permissionArray = [Permissions]()
                        for item in permission{
                            print(item)
                            let itemA = Permissions(json:["id": item["id"] as! Int, "name": item["name"] as! String])
                            permissionArray.append(itemA)
                        }
                        print(permissionArray)
                        let encodedData = NSKeyedArchiver.archivedData(withRootObject: permissionArray)
                        UserDefaults.standard.set(encodedData, forKey: "permissions")
                    }
                }
                break
            case .failure(_):
                //                print( response.result.value!)
                break
            }
        }
                
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("Received: \(userInfo)")
        if  let extraPayLoad  = userInfo["extraPayLoad"] as? [String:Any] {
            let custom =   extraPayLoad["custom"] as? [String:Any]
            if  let type  = custom?["target_type"] as? String {
                if type == "Birthday Message"{
                    UserDefaults.standard.set("1", forKey: "BirthdayMessage")
                }
                if type == "Schedule Messages" {
                    UserDefaults.standard.set("1", forKey: "ScheduleMessages")
                    let id = custom?["target_id"] as? Int
                    UserDefaults.standard.set(id, forKey: "ScheduleMessagesID")
                }
                if let root = self.window?.rootViewController as? UINavigationController {
//                    print(root.topViewController)
                    if type == "Message" {
                        UserDefaults.standard.set("0", forKey: "message_noti")
                        // post a notification
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: nil)
                    }
                }
            }
        }
        completionHandler(.newData)
    }
    // pk_test_BmkdFXRa1UI9WgLqBxc4rsSR00jHWwy3tP
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        STPAPIClient.shared.publishableKey = "pk_live_HkPnSfdA4XdiTy0SSTHQtCzl00r4wXK88s"
        //        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        requestNotification()
        if (UserDefaults.standard.value(forKey: "token") as? String) == nil{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let is_guest = UserDefaults.standard.string(forKey: "is_guest"){
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                let navigationController = UINavigationController(rootViewController: loginViewController)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                _ = UIApplication.shared.delegate as! AppDelegate
                //             print(appdelegate.window!)
                //            print(appdelegate.window!.rootViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            } else {
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
                let navigationController = UINavigationController(rootViewController: loginViewController)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                //             print(appdelegate.window!)
                //            print(appdelegate.window!.rootViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
            //            win
        } else {
            getRoles()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
            let navigationController = UINavigationController(rootViewController: nextViewController)
            //            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            //            appdelegate.window!.rootViewController = navigationController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        // When the app launch after user tap on notification (originally was not running / not in background)
        if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
            // your code here
        }
        Thread.sleep(forTimeInterval: 2)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print(deviceToken)
        //        UserDefaults.standard.set(deviceToken, forKey: "device_token")
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
        //        UserDefaults.standard.set(token, forKey: "device_token")
        //        updateToken(token: token)
        
        // send token to server
    }
    
    //MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
        if let token = fcmToken {
            print("token:",token)
            UserDefaults.standard.set(token, forKey: "device_token")
            //            let sender = PushNotificationSender()
            //            sender.sendPushNotification(to: "\(token)", title: "Guggz", body: "Test")
        }
    }
    // MARK: - Private Methods
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    func requestNotification()  {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    // Schedule Local Notification
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                })
            case .authorized:
                // Schedule Local Notification
                print("authorized")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional:
                print("provisional")
            case .ephemeral:
                print("ephemeral")
            @unknown default:
                print("default")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NewProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // This function will be called when the app receive notification
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //
    //        // show the notification alert (banner), and with sound
    //        completionHandler([.alert, .sound])
    //    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User Info = ",userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let notificationData = userInfo["messageInfo"] as? NSString {
            var dictionary : NSDictionary?
            if let data = notificationData.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let dict = dictionary {
                        if  let type  = dict["target_type"] as? String {
                            let id = dict["target_id"] as? Int
                            print("target_id :", id ?? 0)
                            if  let name  = dict["target_name"] as? String {
                                NotificationHandler.shared.name  = name
                            }
                            if type == "Birthday Message"{
                                UserDefaults.standard.set("1", forKey: "BirthdayMessage")
                            }
                            
                            if type == "Schedule Messages" {
                                UserDefaults.standard.set("1", forKey: "ScheduleMessages")
                                let id = dict["target_id"] as? Int
                                UserDefaults.standard.set(id, forKey: "ScheduleMessagesID")
                            }
                            
                            if (UserDefaults.standard.value(forKey: "token") as? String) == nil{
                                
                                if type == "Guest_Message"{
                                    NotificationHandler.shared.type  = type
                                    NotificationHandler.shared.id  = id ?? 0
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let loginViewController = storyBoard.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                                    let navigationController = UINavigationController(rootViewController: loginViewController)
                                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                    //                    appdelegate.window!.rootViewController = navigationController
                                    self.window = UIWindow(frame: UIScreen.main.bounds)
                                    window?.rootViewController = navigationController
                                    window?.makeKeyAndVisible()
                                }else{
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let loginViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                    let navigationController = UINavigationController(rootViewController: loginViewController)
                                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                    //                    appdelegate.window!.rootViewController = navigationController
                                    self.window = UIWindow(frame: UIScreen.main.bounds)
                                    window?.rootViewController = navigationController
                                    window?.makeKeyAndVisible()
                                }
                                
                            }else{
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
                                NotificationHandler.shared.type  = type
                                NotificationHandler.shared.id  = id ?? 0
                                //                    nextViewController.type = type
                                //                    nextViewController.id
                                //                        = id ?? 0
                                let navigationController = UINavigationController(rootViewController: nextViewController)
                                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                //                    appdelegate.window!.rootViewController = navigationController
                                self.window = UIWindow(frame: UIScreen.main.bounds)
                                window?.rootViewController = navigationController
                                window?.makeKeyAndVisible()
                                
                            }
                        }
                        
                        // ..... and so on
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            }
        }
        
        completionHandler()
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
        if let notificationData = userInfo["messageInfo"] as? NSString {
            var dictionary : NSDictionary?
            if let data = notificationData.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    if let dict = dictionary {
                        if  let type  = dict["target_type"] as? String {
                            if type == "Birthday Message"{
                                UserDefaults.standard.set("1", forKey: "BirthdayMessage")
                            }
                            
                            if type == "Schedule Messages" {
                                UserDefaults.standard.set("1", forKey: "ScheduleMessages")
                                let id = dict["target_id"] as? Int
                                UserDefaults.standard.set(id, forKey: "ScheduleMessagesID")
                            }
                            
                            if let root = self.window?.rootViewController as? UINavigationController {
                                print(root.topViewController)
                                if type == "Message"{
                                    UserDefaults.standard.set("0", forKey: "message_noti")
                                    // post a notification
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: nil)
                                }
                                
                                if type == "Chat"{
                                    
                                    if (root.topViewController is OnetoOneChatVC) {
                                        let onetoone: OnetoOneChatVC = root.topViewController as! OnetoOneChatVC
                                        let id = dict["target_id"] as? Int
                                        let myInt2 = Int(onetoone.receiverId) ?? 0
                                        //                            var idString = "\(id)"
                                        if  myInt2 == id{
                                            
                                            completionHandler([])
                                        }else{
                                            completionHandler([[.alert, .sound]])
                                        }
                                    }else if (root.topViewController is  RecentChatVC){
                                        // call the reload method as well
                                        let recentVC: RecentChatVC = root.topViewController as! RecentChatVC
                                        recentVC.getData()
                                        completionHandler([[.alert, .sound]])
                                    }else{
                                        UserDefaults.standard.set("0", forKey: "noti")
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationChat"), object: nil, userInfo: nil)
                                        completionHandler([[.alert, .sound]])
                                    }
                                    // topController should now be your topmost view controller
                                }else{
                                    completionHandler([[.alert, .sound]])
                                }
                            }else{
                                completionHandler([[.alert, .sound]])
                            }
                            
                        }else{
                            completionHandler([[.alert, .sound]])
                        }
                        
                        // ..... and so on
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            }
        }
    }
    
}

