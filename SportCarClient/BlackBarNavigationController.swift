//
//  BlackBarNavigationController.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/14.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class BlackBarNavigationController: UINavigationController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationBar.tintColor = kBarBgColor
        self.navigationBar.translucent = false
        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: kBarTitleFont]
        self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = kBarBgColor
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit blackbarnavigationController")
    }
}
