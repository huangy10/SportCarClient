//
//  AppLauchner.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/21.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit

let kAppManagerNotificationLogout = "app_manager_notification_logout"

/// 这个类的作用是以全局的角度来调度主要功能模块
class AppManager: UIViewController {
    
    /// 全局的instance对象
    static let sharedAppManager = AppManager()
    var deviceTokenString: String? {
        didSet {
            // TODO: 将这个token上传给服务器
            if MainManager.sharedManager.hostUser == nil {
                
            } else {
                
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launch()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(unreadChange(_:)), name: kNotificationUnreadClearNotification, object: nil)
    }
    
    func unreadChange(notification: NSNotification) {
        let unreadNum = ChatRecordDataSource.sharedDataSource.totalUnreadNum
        UIApplication.sharedApplication().applicationIconBadgeNumber = unreadNum
        // sync to the backend
        ChatRequester.requester.clearNotificationUnreadNum({ (json) in
//            print("success")
            }) { (code) in
//                print("fail")
        }
    }
    
    /**
     启动App，这个函数负责检查登录状态
     */
    func launch() {
        if let _ = MainManager.sharedManager.resumeLoginStatus().hostUser {
            // 当获取到了非nil的hostUser时，直接进入Home界面
            let ctl = HomeController2()
            self.navigationController?.pushViewController(ctl, animated: false)
            return
        }
        let ctl = AccountController()
        let wrapper = BlackBarNavigationController(rootViewController: ctl)
        self.presentViewController(wrapper, animated: false, completion: nil)
    }
    
    func guideToContent() {
        if let _ = MainManager.sharedManager.hostUser {
            let ctl = HomeController2()
            NotificationDataSource.sharedDataSource.start()
            ChatRecordDataSource.sharedDataSource.start()
            self.navigationController?.pushViewController(ctl, animated: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else {
            assertionFailure()
        }
    }
    
    /**
     推出当前所有的展示内容回到登陆页面
     */
    func logout() {
        AccountRequester.sharedRequester.logout({ (json) -> (Void) in
//            print("logout")
            }) { (code) -> (Void) in
//                print("logout fails")
        }
        // 在三个modelmanager上面注销用户
        MainManager.sharedManager.logout()
        ChatModelManger.sharedManager.logout()
        NotificationModelManager.sharedManager.logout()
        // 停止聊天更新
        ChatRecordDataSource.sharedDataSource.pause()
        ChatRecordDataSource.sharedDataSource.flushAll()
        //
        NotificationDataSource.sharedDataSource.pause()
        NotificationDataSource.sharedDataSource.flushAll()
        
        let ctrl = AccountController()
        let nav = BlackBarNavigationController(rootViewController: ctrl)
        self.presentViewController(nav, animated: true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(false)
        NSNotificationCenter.defaultCenter().postNotificationName(kAppManagerNotificationLogout, object: nil)
    }
    
    func login() {
        // TODO: 将登陆功能放到这里来
    }
    
    // push notifications
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func loadHistoricalNotifications(launchOptions: [NSObject: AnyObject]?) {
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            
            print(notification)
        }
    }
}