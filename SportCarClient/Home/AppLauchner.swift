//
//  AppLauchner.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/21.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit

let kAppManagerNotificationLogout = "app_manager_notification_logout"

enum AppManagerState {
    case Init, LoginRegister, Normal
}

/// 这个类的作用是以全局的角度来调度主要功能模块
class AppManager: UIViewController {
    
    /// 全局的instance对象
    static let sharedAppManager = AppManager()
    var deviceTokenString: String? = "Unauthorized_Device"
    
    var state: AppManagerState = .Init
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launch()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(unreadChange(_:)), name: kUnreadNumberDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUserForceOffline(_:)), name: kAccontNolongerLogin, object: nil)
    }
    
    func unreadChange(notification: NSNotification) {
        let unreadNum = MessageManager.defaultManager.unreadNum
        UIApplication.sharedApplication().applicationIconBadgeNumber = unreadNum
        // sync to the backend
//        ChatRequester.requester.clearNotificationUnreadNum({ (json) in
////            print("success")
//            }) { (code) in
////                print("fail")
//        }
    }
    
    /**
     启动App，这个函数负责检查登录状态
     */
    func launch() {
        if let _ = MainManager.sharedManager.resumeLoginStatus().hostUser {
            // 当获取到了非nil的hostUser时，直接进入Home界面
            state = .Normal
            let ctl = HomeController2()
            self.navigationController?.pushViewController(ctl, animated: false)
            return
        }
        state = .LoginRegister
        let ctl = AccountController()
        let wrapper = BlackBarNavigationController(rootViewController: ctl, blackNavTitle: true)
        self.presentViewController(wrapper, animated: false, completion: nil)
    }
    
    func guideToContent() {
        state = .Normal
        if let _ = MainManager.sharedManager.hostUser {
            let ctl = HomeController2()
//            NotificationDataSource.sharedDataSource.start()
            self.navigationController?.pushViewController(ctl, animated: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else {
            assertionFailure()
        }
    }
    
    /**
     推出当前所有的展示内容回到登陆页面
     */
    func logout(forced: Bool = false) {
        state = .LoginRegister
        if !forced {
            AccountRequester2.sharedInstance.logout({ (json) -> (Void) in
                print("logout")
                }) { (code) -> (Void) in
                    print("logout fails")
            }
        }
        // 在三个modelmanager上面注销用户
        MainManager.sharedManager.logout()
        ChatModelManger.sharedManager.logout()
        // 停止聊天更新
        MessageManager.defaultManager.disconnect()
//        ChatRecordDataSource.sharedDataSource.pause()
//        ChatRecordDataSource.sharedDataSource.flushAll()
        //
//        NotificationDataSource.sharedDataSource.pause()
//        NotificationDataSource.sharedDataSource.flushAll()
        
        let ctrl = AccountController()
        let nav = BlackBarNavigationController(rootViewController: ctrl, blackNavTitle: true)
        self.presentViewController(nav, animated: true, completion: {
            if forced {
                ctrl.showToast(LS("您的账号在其他设备上登陆了"))
            }
        })
        self.navigationController?.popToRootViewControllerAnimated(false)
        NSNotificationCenter.defaultCenter().postNotificationName(kAppManagerNotificationLogout, object: nil)
    }
    
    func login() {
        // TODO: 将登陆功能放到这里来
        state = .Normal
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
    
    /**
     强制用户下线重新登录
     */
    func onUserForceOffline(notif: NSNotification) {
        // logout the user
        dispatch_async(dispatch_get_main_queue()) { 
            self.logout(true)
        }
    }
}