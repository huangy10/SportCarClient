//
//  StatusHome.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/20.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


enum StatusHomeDisplayMode {
    case NearBy
    case Follow
    case HotTopic
}


class StatusHomeController: UIViewController, UIScrollViewDelegate {
    var homeDelegate: HomeDelegate?
    
    var displayStatus: StatusHomeDisplayMode = .NearBy
    // 三个tableView
    var nearByStatusCtrl = StatusBasicController()
    var followStatusCtrl = StatusFollowController()
    var hotStatausCtrl = StatusBasicController()
    //
    var board: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    internal func createSubviews() {
        let superview = self.view
        //
        board = UIScrollView()
        board?.pagingEnabled = true
        let screenSize = superview.frame.size
//        board?.contentSize = CGSizeMake(screenSize.width * 3, screenSize.height)
        superview.addSubview(board!)
        board?.frame = superview.bounds
        // 关注
        followStatusCtrl.homeController = self
        let followView = followStatusCtrl.view
        superview.addSubview(followView)
        followView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
    }
    
    internal func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("动态")
        //
        // 导航栏左侧按钮
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 15, 13.5)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        // 导航栏右侧按钮
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        // 导航栏内容
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView(frame: CGRectMake(0, 0, containerWidth, barHeight))
        container.backgroundColor = UIColor.clearColor()
        
    }
    
    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
        homeDelegate?.backToHome(nil, screenShot: self.getScreenShotBlurred(false)) 
    }
    
    func navRightBtnPressed() {
        let release = StatusReleaseController()
        release.home = self
        let wrapper = BlackBarNavigationController(rootViewController: release)
        self.presentViewController(wrapper, animated: true, completion: nil)
    }
}