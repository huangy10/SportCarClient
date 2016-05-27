//
//  BlackBarNavigationController.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/14.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit

// Due to historical reason, the name contians "black"
class BlackBarNavigationController: UINavigationController {
    
    // whether the navigation bar is black or not. false for default
    var blackNavTitle: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if blackNavTitle {
            self.navigationBar.tintColor = kBarBgColor
            self.navigationBar.translucent = false
            self.navigationBar.barStyle = UIBarStyle.Black
            self.navigationBar.titleTextAttributes = [NSFontAttributeName: kBarTitleFont]
            self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = kBarBgColor
        } else {
            self.navigationBar.tintColor = UIColor(white: 0.996, alpha: 0)
            self.navigationBar.translucent = false
            self.navigationBar.barStyle = UIBarStyle.Default
            self.navigationBar.titleTextAttributes = [NSFontAttributeName: kBarTitleFont]
            self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.backgroundColor = kBarBgColor
            self.navigationBar.addShadow(0, color: UIColor.blackColor(), opacity: 0.12, offset: CGSizeMake(0, 1))
        }
    }
    
    convenience init(rootViewController: UIViewController, blackNavTitle: Bool) {
        self.init(rootViewController: rootViewController)
        self.blackNavTitle = blackNavTitle
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
