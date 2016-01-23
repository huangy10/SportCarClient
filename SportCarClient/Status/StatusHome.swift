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
    var displayStatus: StatusHomeDisplayMode = .NearBy
    // 三个tableView
    var nearByStatusCtrl = StatusBasicController()
    var followStatusCtrl = StatusFollowController()
    var hotStatausCtrl = StatusBasicController()
    //
    var board: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        navSettings()
    }
    
    internal func createSubviews() {
        let superview = self.view
        //
        board = UIScrollView()
        board?.pagingEnabled = true
        let screenSize = superview.frame.size
        board?.contentSize = CGSizeMake(screenSize.width * 3, screenSize.height)
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
        self.navigationController?.title = LS("关注")
    }
}