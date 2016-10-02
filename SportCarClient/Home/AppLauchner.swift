//
//  AppLauchner.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/21.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import AudioToolbox

let kAppManagerNotificationLogout = "app_manager_notification_logout"

enum AppManagerState {
    case `init`, loginRegister, normal
}

/// 这个类的作用是以全局的角度来调度主要功能模块
class AppManager: UIViewController {
    
    /// 全局的instance对象
    static let sharedAppManager = AppManager()
    var deviceTokenString: String? = "Unauthorized_Device"
    
    var state: AppManagerState = .init
    
    weak var homeController: HomeController2?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launch()
        NotificationCenter.default.addObserver(self, selector: #selector(unreadChange(_:)), name: NSNotification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserForceOffline(_:)), name: NSNotification.Name(rawValue: kAccontNolongerLogin), object: nil)
    }
    
    func unreadChange(_ notification: Foundation.Notification) {
        let unreadNum = MessageManager.defaultManager.unreadNum
        UIApplication.shared.applicationIconBadgeNumber = unreadNum
        // sync to the backend
    }
    
    /**
     启动App，这个函数负责检查登录状态
     */
    func launch() {
        if let _ = MainManager.sharedManager.resumeLoginStatus().hostUser {
            // 当获取到了非nil的hostUser时，直接进入Home界面
            state = .normal
            let ctl = HomeController2()
            self.navigationController?.pushViewController(ctl, animated: false)
            return
        }
        state = .loginRegister
        let ctl = AccountController()
        let wrapper = BlackBarNavigationController(rootViewController: ctl, blackNavTitle: true)
        self.present(wrapper, animated: false, completion: nil)
    }
    
    func guideToContent() {
        state = .normal
        if let _ = MainManager.sharedManager.hostUser {
            let ctl = HomeController2()
            homeController = ctl
//            NotificationDataSource.sharedDataSource.start()
            self.navigationController?.pushViewController(ctl, animated: false)
            self.dismiss(animated: true, completion: nil)
        }else {
            assertionFailure()
        }
    }
    
    /**
     推出当前所有的展示内容回到登陆页面
     */
    func logout(_ forced: Bool = false) {
        state = .loginRegister
        if !forced {
            _ = AccountRequester2.sharedInstance.logout({ (json) -> (Void) in
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
        self.present(nav, animated: true, completion: {
            if forced {
                ctrl.showToast(LS("您的账号在其他设备上登陆了"))
            }
        })
        _ = self.navigationController?.popToRootViewController(animated: false)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kAppManagerNotificationLogout), object: nil)
    }
    
    func login() {
        // TODO: 将登陆功能放到这里来
        state = .normal
    }
    
    // push notifications
    
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func loadHistoricalNotifications(_ launchOptions: [AnyHashable: Any]?) {
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            print(notification)
        }
    }
    
    @available(*, deprecated: 1)
    func onReceiveNewRemoteNotificaiton(_ userInfo: [AnyHashable: Any]) {
        let state = UIApplication.shared.applicationState
        switch state {
        case .active:
            return
        default:
            break
        }
        if let aps = userInfo["aps"] as? NSDictionary {
            if let soundType = aps["sound"] as? String {
                switch soundType {
                case "default":
                    playRemoteNotificaitonSound()
                    shakeWhenRemoteNotificationComes()
                case "no_sound":
                    shakeWhenRemoteNotificationComes()
                case "no_shake":
                    playRemoteNotificaitonSound()
                default:
                    break
                }
            }
        }
    }
    
    func playRemoteNotificaitonSound() {
        AudioServicesPlaySystemSound(1007)
    }
    
    func shakeWhenRemoteNotificationComes() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /**
     强制用户下线重新登录
     */
    func onUserForceOffline(_ notif: Foundation.Notification) {
        // logout the user
        DispatchQueue.main.async { 
            self.logout(true)
        }
    }
}
