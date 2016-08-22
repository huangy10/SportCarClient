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
    
    var titleNearbyLbl: UILabel!
    var titleFollowLbl: UILabel!
    var titleHotLbl: UILabel!
    var titleIcon: UIImageView!
    
    private var _curTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
//        controllers[_curTag].viewWillAppear(animated)
        navLeftBtn.unreadStatusChanged()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
//        controllers[_curTag].viewWillDisappear(true)
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
        addChildViewController(followStatusCtrl)
        let followView = followStatusCtrl.view
        board.addSubview(followView)
        followView.frame = CGRectMake(screenSize.width, 0, screenSize.width, rect.height)
        followStatusCtrl.didMoveToParentViewController(self)
        //
        hotStatusCtrl.homeController = self
        addChildViewController(hotStatusCtrl)
        let hotView = hotStatusCtrl.view
        board.addSubview(hotView)
        hotView.frame = CGRectMake(screenSize.width * 2, 0, screenSize.width, rect.height)
        hotStatusCtrl.didMoveToParentViewController(self)
        // 附近
        nearByStatusCtrl.homeController = self
        addChildViewController(nearByStatusCtrl)
        let nearbyView = nearByStatusCtrl.view
        board.addSubview(nearbyView)
        nearbyView.frame = CGRectMake(0, 0, screenSize.width, rect.height)
        nearByStatusCtrl.didMoveToParentViewController(self)
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
        navRightBtn.frame = CGRectMake(0, 0, 18, 18)
        navRightBtn.addTarget(self, action: #selector(StatusHomeController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        // 导航栏内容
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView(frame: CGRectMake(0, 0, containerWidth, barHeight))
        container.backgroundColor = UIColor.clearColor()
        
        let titleFollowBtn = UIButton()
        titleFollowBtn.tag = 1
        titleFollowBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleFollowBtn)
        titleFollowBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.center.equalTo(container)
        }
        titleFollowLbl = titleFollowBtn.addSubview(UILabel)
            .config(15, textColor: kTextBlack, textAlignment: .Center, text: LS("关注"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleFollowBtn)
                make.size.equalTo(LS(" 关注 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        
        let titleNearbyBtn = UIButton()
        titleNearbyBtn.tag = 0
        titleNearbyBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleNearbyBtn)
        titleNearbyBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(container)
            make.right.equalTo(titleFollowBtn.snp_left)
            make.size.equalTo(CGSizeMake(70, 30))
        }
        titleNearbyLbl = titleNearbyBtn.addSubview(UILabel)
            .config(15, textColor: kTextGray, textAlignment: .Center, text: LS("附近"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleNearbyBtn)
                make.size.equalTo(LS(" 附近 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        
        let titleHotBtn = UIButton()
        titleHotBtn.tag = 2
        titleHotBtn.addTarget(self, action: #selector(navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(titleHotBtn)
        titleHotBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(titleFollowBtn.snp_right)
            make.centerY.equalTo(container)
            make.size.equalTo(CGSizeMake(70, 30))
        }
        titleHotLbl = titleHotBtn.addSubview(UILabel)
            .config(15, textColor: kTextGray, textAlignment: .Center, text: LS("热门"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleHotBtn)
                make.size.equalTo(LS(" 热门 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        
        titleIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleIcon)
        titleIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(titleFollowLbl)
            make.right.equalTo(titleFollowLbl)
            make.bottom.equalTo(container)
            make.height.equalTo(2.5)
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
        let lbls = [titleNearbyLbl, titleFollowLbl, titleHotLbl]
        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
        controllers[_curTag].viewWillDisappear(true)
        controllers[sender.tag].viewWillAppear(true)
        let targetLbl = lbls[sender.tag]
        let sourceLbl = lbls[_curTag]
        targetLbl.textColor = kTextBlack
        sourceLbl.textColor = kTextGray
        titleIcon.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(titleIcon.superview!)
            make.left.equalTo(targetLbl)
            make.right.equalTo(targetLbl)
            make.height.equalTo(2.5)
        }
        UIView.animateWithDuration(0.2) { () -> Void in
            self.titleIcon.superview?.layoutIfNeeded()
        }
        board.setContentOffset(CGPointMake(self.view.frame.width * CGFloat(sender.tag), 0), animated: true)
        _curTag = sender.tag
    }
}