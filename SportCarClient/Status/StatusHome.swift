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
    
    weak var homeDelegate: HomeDelegate?
    
    var displayStatus: StatusHomeDisplayMode = .NearBy
    // 三个tableView
    var nearByStatusCtrl = StatusNearbyController()
    var followStatusCtrl = StatusFollowController()
    var hotStatusCtrl = StatusHotController()
    //
    var navLeftBtn: BackToHomeBtn!
    var board: UIScrollView!
    
    var titleNearbyBtn: UIButton!
    var titleFollowBtn: UIButton!
    var titleHotBtn: UIButton!
    var titleIcon: UIImageView!
    
    private var _curTag = 1
    
    deinit {
        print("deinit status home")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
        controllers[_curTag].viewWillAppear(animated)
        navLeftBtn.unreadStatusChanged()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
        controllers[_curTag].viewWillDisappear(true)
    }
    
    internal func createSubviews() {
        let superview = self.view
        //
        board = UIScrollView()
        board.pagingEnabled = true
        board.scrollEnabled = false
        let screenSize = superview.frame.size
        board.contentSize = CGSizeMake(screenSize.width * 3, screenSize.height)
        board.setContentOffset(CGPointMake(screenSize.width, 0), animated: true)
        superview.addSubview(board!)
        var rect = superview.bounds
        rect.size.height -= 44 + 20
        board.frame = rect
        // 关注
        followStatusCtrl.homeController = self
        let followView = followStatusCtrl.view
        board.addSubview(followView)
        followView.frame = CGRectMake(screenSize.width, 0, screenSize.width, rect.height)
        //
        hotStatusCtrl.homeController = self
        let hotView = hotStatusCtrl.view
        board.addSubview(hotView)
        hotView.frame = CGRectMake(screenSize.width * 2, 0, screenSize.width, rect.height)
        // 附近
        nearByStatusCtrl.homeController = self
        let nearbyView = nearByStatusCtrl.view
        board.addSubview(nearbyView)
        nearbyView.frame = CGRectMake(0, 0, screenSize.width, rect.height)
    }
    
    internal func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 导航栏左侧按钮
        navLeftBtn = BackToHomeBtn()
        navLeftBtn.addTarget(self, action: #selector(navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = navLeftBtn.wrapToBarBtn()
        // 导航栏右侧按钮
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.addTarget(self, action: #selector(StatusHomeController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        // 导航栏内容
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView(frame: CGRectMake(0, 0, containerWidth, barHeight))
        container.backgroundColor = UIColor.clearColor()
        
        titleFollowBtn = UIButton()
        titleFollowBtn.tag = 1
        titleFollowBtn.setTitle(LS("关注"), forState: .Normal)
        titleFollowBtn.setTitleColor(kBarBgColor, forState: .Normal)
        titleFollowBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        titleFollowBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleFollowBtn)
        titleFollowBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.center.equalTo(container)
        }
        
        titleNearbyBtn = UIButton()
        titleNearbyBtn.tag = 0
        titleNearbyBtn.setTitle(LS("附近"), forState: .Normal)
        titleNearbyBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleNearbyBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        titleNearbyBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleNearbyBtn)
        titleNearbyBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(container)
            make.right.equalTo(titleFollowBtn.snp_left).offset(-9)
            make.size.equalTo(CGSizeMake(80, 30))
        }
        
        titleHotBtn = UIButton()
        titleHotBtn.tag = 2
        titleHotBtn.setTitle(LS("热门"), forState: .Normal)
        titleHotBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleHotBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        titleHotBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleHotBtn)
        titleHotBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(titleFollowBtn.snp_right).offset(9)
            make.centerY.equalTo(container)
            make.size.equalTo(CGSizeMake(80, 30))
        }
        
        titleIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleIcon)
        titleIcon.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(titleFollowBtn)
        }
        container.sendSubviewToBack(titleIcon)
        self.navigationItem.titleView = container
    }
    
    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
        homeDelegate?.backToHome(nil)
    }
    
    func navRightBtnPressed() {
        let release = StatusReleaseController()
        release.home = self
        release.pp_presentWithWrapperFromController(self)
    }
    
    func navTitleBtnPressed(sender: UIButton) {
        if sender.tag == _curTag {
            // current button is pressed, do nothing
            return
        }
        let btns = [titleNearbyBtn, titleFollowBtn, titleHotBtn]
        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
        controllers[_curTag].viewWillDisappear(true)
        controllers[sender.tag].viewWillAppear(true)
        let targetBtn = btns[sender.tag]
        let sourceBtn = btns[_curTag]
        targetBtn.setTitleColor(kBarBgColor, forState: .Normal)
        sourceBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleIcon.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(targetBtn)
        }
        UIView.animateWithDuration(0.2) { () -> Void in
            self.titleIcon.superview?.layoutIfNeeded()
        }
        board.setContentOffset(CGPointMake(self.view.frame.width * CGFloat(sender.tag), 0), animated: true)
        _curTag = sender.tag
    }
}