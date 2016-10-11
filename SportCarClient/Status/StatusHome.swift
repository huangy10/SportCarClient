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
    case nearBy
    case follow
    case hotTopic
}


class StatusHomeController: UIViewController, UIScrollViewDelegate {
    
    weak var homeDelegate: HomeDelegate?
    
    var displayStatus: StatusHomeDisplayMode = .nearBy
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
    
    fileprivate var _curTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
//        controllers[_curTag].viewWillAppear(animated)
        navLeftBtn.unreadStatusChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl]
//        controllers[_curTag].viewWillDisappear(true)
    }
    
    internal func createSubviews() {
        let superview = self.view
        //
        board = UIScrollView()
        board.isPagingEnabled = true
        board.isScrollEnabled = false
        let screenSize = superview?.frame.size
        board.contentSize = CGSize(width: (screenSize?.width)! * 3, height: (screenSize?.height)!)
        board.setContentOffset(CGPoint(x: (screenSize?.width)!, y: 0), animated: true)
        superview?.addSubview(board!)
        var rect = superview?.bounds
        rect?.size.height -= 44 + 20
        board.frame = rect!
        // 关注
        followStatusCtrl.homeController = self
        addChildViewController(followStatusCtrl)
        let followView = followStatusCtrl.view
        board.addSubview(followView!)
        followView?.frame = CGRect(x: (screenSize?.width)!, y: 0, width: (screenSize?.width)!, height: (rect?.height)!)
        followStatusCtrl.didMove(toParentViewController: self)
        //
        hotStatusCtrl.homeController = self
        addChildViewController(hotStatusCtrl)
        let hotView = hotStatusCtrl.view
        board.addSubview(hotView!)
        hotView?.frame = CGRect(x: (screenSize?.width)! * 2, y: 0, width: (screenSize?.width)!, height: (rect?.height)!)
        hotStatusCtrl.didMove(toParentViewController: self)
        // 附近
        nearByStatusCtrl.homeController = self
        addChildViewController(nearByStatusCtrl)
        let nearbyView = nearByStatusCtrl.view
        board.addSubview(nearbyView!)
        nearbyView?.frame = CGRect(x: 0, y: 0, width: (screenSize?.width)!, height: (rect?.height)!)
        nearByStatusCtrl.didMove(toParentViewController: self)
    }
    
    internal func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 导航栏左侧按钮
        navLeftBtn = BackToHomeBtn()
        navLeftBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = navLeftBtn.wrapToBarBtn()
        // 导航栏右侧按钮
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), for: .normal)
        navRightBtn.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        navRightBtn.addTarget(self, action: #selector(StatusHomeController.navRightBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        // 导航栏内容
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: barHeight))
        container.backgroundColor = UIColor.clear
        
        let titleFollowBtn = UIButton()
        titleFollowBtn.tag = 1
        titleFollowBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(titleFollowBtn)
        titleFollowBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.center.equalTo(container)
        }
        titleFollowLbl = titleFollowBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightSemibold, textColor: kTextGray87, textAlignment: .center, text: LS("关注"))
            .layout({ (make) in
                make.center.equalTo(titleFollowBtn)
                make.size.equalTo(LS(" 关注 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        
        let titleNearbyBtn = UIButton()
        titleNearbyBtn.tag = 0
        titleNearbyBtn.addTarget(self, action: #selector(StatusHomeController.navTitleBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(titleNearbyBtn)
        titleNearbyBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(container)
            make.right.equalTo(titleFollowBtn.snp.left)
            make.size.equalTo(CGSize(width: 70, height: 30))
        }
        titleNearbyLbl = titleNearbyBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightSemibold, textColor: kTextGray54, textAlignment: .center, text: LS("附近"))
            .layout({ (make) in
                make.center.equalTo(titleNearbyBtn)
                make.size.equalTo(LS(" 附近 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        
        let titleHotBtn = UIButton()
        titleHotBtn.tag = 2
        titleHotBtn.addTarget(self, action: #selector(navTitleBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(titleHotBtn)
        titleHotBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(titleFollowBtn.snp.right)
            make.centerY.equalTo(container)
            make.size.equalTo(CGSize(width: 70, height: 30))
        }
        titleHotLbl = titleHotBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightSemibold, textColor: kTextGray54, textAlignment: .center, text: LS("热门"))
            .layout({ (make) in
                make.center.equalTo(titleHotBtn)
                make.size.equalTo(LS(" 热门 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        
        titleIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleIcon)
        titleIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(titleFollowLbl)
            make.right.equalTo(titleFollowLbl)
            make.bottom.equalTo(container)
            make.height.equalTo(2.5)
        }
        container.sendSubview(toBack: titleIcon)
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
    
    func navTitleBtnPressed(_ sender: UIButton) {
        if sender.tag == _curTag {
            // current button is pressed, do nothing
            return
        }
        let lbls = [titleNearbyLbl, titleFollowLbl, titleHotLbl]
        let controllers = [nearByStatusCtrl, followStatusCtrl, hotStatusCtrl] as [Any]
        (controllers[_curTag] as AnyObject).viewWillDisappear(true)
        (controllers[sender.tag] as AnyObject).viewWillAppear(true)
        let targetLbl = lbls[sender.tag]!
        let sourceLbl = lbls[_curTag]!
        targetLbl.textColor = kTextGray87
        sourceLbl.textColor = kTextGray54
        titleIcon.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalTo(titleIcon.superview!)
            make.left.equalTo(targetLbl)
            make.right.equalTo(targetLbl)
            make.height.equalTo(2.5)
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.titleIcon.superview?.layoutIfNeeded()
        }) 
        board.setContentOffset(CGPoint(x: self.view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
        _curTag = sender.tag
    }
}
