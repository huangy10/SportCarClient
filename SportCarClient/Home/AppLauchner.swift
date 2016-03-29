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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launch()
    }
    
    /**
     启动App，这个函数负责检查登录状态
     */
    func launch() {
        if let hostUser = MainManager.sharedManager.resumeLoginStatus().hostUser {
            // 当获取到了非nil的hostUser时，直接进入Home界面
            let ctl = HomeController()
            ctl.hostUser = hostUser
            self.navigationController?.pushViewController(ctl, animated: false)
            return
        }
        let ctl = AccountController()
        let wrapper = BlackBarNavigationController(rootViewController: ctl)
        self.presentViewController(wrapper, animated: false, completion: nil)
    }
    
    func guideToContent() {
        if let hostUser = MainManager.sharedManager.hostUser {
            let ctl = HomeController()
            NotificationDataSource.sharedDataSource.start()
            ChatRecordDataSource.sharedDataSource.start()
            ctl.hostUser = hostUser
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
}