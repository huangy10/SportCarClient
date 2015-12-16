//
//  AccountController.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/7.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class AccountController: UIViewController{
    /**
    *  这个类是注册登陆模块的最顶层容器
    */
    var loginRegisterCtrl: LoginRegisterController?
    
    override func viewDidLoad() {
        loginRegisterCtrl = LoginRegisterController()
        self.navigationController?.pushViewController(loginRegisterCtrl!, animated: false)
    }
}
