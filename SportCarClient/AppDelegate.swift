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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, WXApiDelegate, WeiboSDKDelegate {

    var window: UIWindow?
    var mapManager: BMKMapManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
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
//        let path = Bundle.main.path(forResource: "custom_config_黑夜", ofType: "")
//        BMKMapView.customMapStyle(path)
//        
    }
    
    func imageCacheSettings() {
        let cache = KingfisherManager.shared.cache
        // Set max disk cache to 50 mb. Default is no limit.
        cache.maxDiskCacheSize = UInt(50 * 1024 * 1024)
    }
    
    func shareSetup() {
        WXApi.registerApp("wx9dbf7503327ee98c")
        WeiboSDK.registerApp("2005077014")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game
        MessageManager.defaultManager.disconnect()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        MessageManager.defaultManager.disconnect()
        try! ChatModelManger.sharedManager.save()
        try! MainManager.sharedManager.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        MessageManager.defaultManager.connect()
        if MainManager.sharedManager.hostUser != nil {
            PersonMineSettingsDataSource.sharedDataSource.update()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        try! ChatModelManger.sharedManager.save()
        try! MainManager.sharedManager.save()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // handle real time notification
//        AppManager.sharedAppManager.onReceiveNewRemoteNotificaiton(userInfo)
    }
    
//    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
//        if notificationSettings.types != UIUserNotificationType() {
//            application.registerForRemoteNotifications()
//        } else {
//            AppManager.sharedAppManager.deviceTokenString = "UnauthorizedDevice"
//        }
//    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        AppManager.sharedAppManager.deviceTokenString = tokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func onGetNetworkState(_ iError: Int32) {
        
    }
    
    func onGetPermissionState(_ iError: Int32) {
        
    }
    
    
    // MARK: - Delegate for Share
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let urlStr = url.absoluteString
        if urlStr.hasPrefix("wx") {
            return WXApi.handleOpen(url, delegate: self);
        } else if urlStr.hasSuffix("wb") {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else {
            return false
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let urlStr = url.absoluteString
        if urlStr.hasPrefix("wx") {
            return WXApi.handleOpen(url, delegate: self);
        } else if urlStr.hasSuffix("wb") {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else if urlStr.hasSuffix("mqq"){
            return TencentOAuth.handleOpen(url)
        } else {
            return false
        }
    }
    
    // MARK: Wechat
    
    func onReq(_ req: BaseReq!) {
        
    }
    
    func onResp(_ resp: BaseResp!) {
        
    }
    
    // MARK: Sina Weibo
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        print(request)
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        print(response)
    }


}

