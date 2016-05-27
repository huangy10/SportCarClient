//
//  AppDelegate.swift
//  SportCarClient
//
//  Created by 黄延 on 15/11/25.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, WXApiDelegate, WeiboSDKDelegate {

    var window: UIWindow?
    var mapManager: BMKMapManager?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        mapManager = BMKMapManager()
        let ret = mapManager?.start("WFZ49PN014ukXD2S4Guqxja2", generalDelegate: self)
        assert(ret!)
        customizeMap()
        shareSetup()
        let home = AppManager.sharedAppManager     				
        let wrapper = BlackBarNavigationController(rootViewController: home, blackNavTitle: true)
        window?.rootViewController = wrapper
        window?.makeKeyAndVisible()
        home.registerForPushNotifications(application)
        home.loadHistoricalNotifications(launchOptions)
        return true
    }
    
    func customizeMap() {
        let path = NSBundle.mainBundle().pathForResource("custom_config_黑夜", ofType: "")
        BMKMapView.customMapStyle(path)
    }
    
    func imageCacheSettings() {
        let cache = KingfisherManager.sharedManager.cache
        // Set max disk cache to 50 mb. Default is no limit.
        cache.maxDiskCacheSize = 50 * 1024 * 1024
    }
    
    func shareSetup() {
        WXApi.registerApp("wx9dbf7503327ee98c")
        WeiboSDK.registerApp("2005077014")
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game
        MessageManager.defaultManager.disconnect()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Save Core Data")
        try! ChatModelManger.sharedManager.save()
        try! MainManager.sharedManager.save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        MessageManager.defaultManager.connect()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("Save Core Data")
        try! ChatModelManger.sharedManager.save()
        try! MainManager.sharedManager.save()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // handle real time notification
        
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        } else {
            AppManager.sharedAppManager.deviceTokenString = "UnauthorizedDevice"
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        AppManager.sharedAppManager.deviceTokenString = tokenString
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }

//    // MARK: - Core Data stack
//
//    lazy var applicationDocumentsDirectory: NSURL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.woodyhuang.SportCarClient" in the application's documents Application Support directory.
//        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        return urls[urls.count-1]
//    }()
//
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = NSBundle.mainBundle().URLForResource("SportCarClient", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//    }()
//
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        // Create the coordinator and store
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
//        var failureReason = "There was an error creating or loading the application's saved data."
//        do {
//            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
//        } catch {
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//
//            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
//        }
//        
//        return coordinator
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//        }
//    }
    
    func onGetNetworkState(iError: Int32) {
        print(iError)
    }
    
    func onGetPermissionState(iError: Int32) {
        print(iError)
    }
    
    
    // MARK: - Delegate for Share
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let urlStr = url.absoluteString
        if urlStr.hasPrefix("wx") {
            return WXApi.handleOpenURL(url, delegate: self);
        } else if urlStr.hasSuffix("wb") {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        } else {
            return false
        }
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let urlStr = url.absoluteString
        if urlStr.hasPrefix("wx") {
            return WXApi.handleOpenURL(url, delegate: self);
        } else if urlStr.hasSuffix("wb") {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        } else if urlStr.hasSuffix("mqq"){
            return TencentOAuth.HandleOpenURL(url)
        } else {
            return false
        }
    }
    
    // MARK: Wechat
    
    func onReq(req: BaseReq!) {
        
    }
    
    func onResp(resp: BaseResp!) {
        
    }
    
    // MARK: Sina Weibo
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        
    }


}

