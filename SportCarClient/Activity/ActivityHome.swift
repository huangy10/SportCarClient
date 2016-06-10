//
//  ActivityHome.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  活动的模块的入口
//

import UIKit


class ActivityHomeController: UIViewController {
    
    weak var homeDelegate: HomeDelegate?
    
//    var nearBy: ActivityNearByController!
    var mine: ActivityHomeMineListController!
    var applied: ActivityAppliedController!
    var controllers: [UIViewController] = []
    
    var board: UIScrollView!
//    var titleNearByBtn: UIButton!
    var titleMineLbl: UILabel!
    var titleAppliedLbl: UILabel!
    var titleBtnIcon: UIImageView!
    var curTag: Int = 0
    
    var navLeftBtn: BackToHomeBtn!
    
    deinit {
        print("deinit activity home controller")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        controllers[curTag].viewWillAppear(animated)
        navLeftBtn.unreadStatusChanged()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        controllers[curTag].viewWillDisappear(animated)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // 导航栏左侧按钮
        navLeftBtn = BackToHomeBtn()
        navLeftBtn.addTarget(self, action: #selector(navLeftBtnPressed), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = navLeftBtn.wrapToBarBtn()
        // 导航栏右侧按钮
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 18, 18)
        navRightBtn.addTarget(self, action: #selector(ActivityHomeController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        // 导航栏内容
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView(frame: CGRectMake(0, 0, containerWidth, barHeight))
        container.backgroundColor = UIColor.clearColor()
        
        let titleMineBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(navTitleBtnPressed(_:)))
            .layout({ (make) in
                make.right.equalTo(container.snp_centerX)
                make.centerY.equalTo(container)
                make.size.equalTo(CGSizeMake(70, 30))
            })
        titleMineBtn.tag = 0
        titleMineLbl = titleMineBtn.addSubview(UILabel)
            .config(15, textColor: kTextBlack, textAlignment: .Center, text: LS("已发布"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleMineBtn)
                make.size.equalTo(LS(" 已发布 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        
        let titleAppliedBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(navTitleBtnPressed(_:)))
            .layout({ (make) in
                make.left.equalTo(container.snp_centerX)
                make.centerY.equalTo(container)
                make.size.equalTo(CGSizeMake(70, 30))
            })
        titleAppliedBtn.tag = 1
        titleAppliedLbl = titleAppliedBtn.addSubview(UILabel)
            .config(15, textColor: kTextGray, textAlignment: .Center, text: LS("已报名"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleAppliedBtn)
                make.size.equalTo(LS(" 已报名 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
//        //
//        titleMineBtn = UIButton()
//        titleMineBtn.tag = 1
//        titleMineBtn.setTitle(LS("发布"), forState: .Normal)
//        titleMineBtn.setTitleColor(kBarBgColor, forState: .Normal)
//        titleMineBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
//        titleMineBtn.addTarget(self, action: #selector(ActivityHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
//        container.addSubview(titleMineBtn)
//        titleMineBtn.snp_makeConstraints { (make) -> Void in
//            make.height.equalTo(30)
//            make.width.equalTo(80)
//            make.center.equalTo(container)
//        }
//        //
//        titleNearByBtn = UIButton()
//        titleNearByBtn.tag = 0
//        titleNearByBtn.setTitle(LS("发现"), forState: .Normal)
//        titleNearByBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        titleNearByBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
//        titleNearByBtn.addTarget(self, action: #selector(ActivityHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
//        container.addSubview(titleNearByBtn)
//        titleNearByBtn.snp_makeConstraints { (make) -> Void in
//            make.centerY.equalTo(container)
//            make.right.equalTo(titleMineBtn.snp_left).offset(-9)
//            make.size.equalTo(CGSizeMake(80, 30))
//        }
//        //
//        titleAppliedBtn = UIButton()
//        titleAppliedBtn.setTitle(LS("已报"), forState: .Normal)
//        titleAppliedBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        titleAppliedBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
//        titleAppliedBtn.tag = 2
//        titleAppliedBtn.addTarget(self, action: #selector(ActivityHomeController.navTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
//        container.addSubview(titleAppliedBtn)
//        titleAppliedBtn.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(titleMineBtn.snp_right).offset(9)
//            make.centerY.equalTo(container)
//            make.size.equalTo(CGSizeMake(80, 30))
//        }
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(container)
            make.left.equalTo(titleMineLbl)
            make.right.equalTo(titleMineLbl)
            make.height.equalTo(2.5)
        }
        container.sendSubviewToBack(titleBtnIcon)
        //
        self.navigationItem.titleView = container
    }
    
    func navTitleBtnPressed(sender: UIButton) {
        if sender.tag == curTag {
            return
        }
        controllers[sender.tag].viewWillAppear(true)
        controllers[curTag].viewWillDisappear(true)
        
        let lbls = [titleMineLbl, titleAppliedLbl]
        let targetLbl = lbls[sender.tag]
        let sourceLbl = lbls[curTag]
        targetLbl.textColor = kTextBlack
        sourceLbl.textColor = kTextGray
        
        titleBtnIcon.snp_remakeConstraints { (make) -> Void in
            make.bottom.equalTo(titleBtnIcon.superview!)
            make.left.equalTo(targetLbl)
            make.right.equalTo(targetLbl)
            make.height.equalTo(2.5)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.titleBtnIcon.superview?.layoutIfNeeded()
            }, completion: nil)
        board.setContentOffset(CGPointMake(self.view.frame.width * CGFloat(sender.tag), 0), animated: true)
        curTag = sender.tag
    }
    
    func navLeftBtnPressed() {
        homeDelegate?.backToHome(nil)
    }
    
    func navRightBtnPressed() {
        let release = ActivityReleasePresentableController()
        release.presentFrom(self)
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        
        board = UIScrollView()
        board.pagingEnabled = true
        board.scrollEnabled = false
        let width = superview.frame.width
        let height = superview.frame.height
        board.contentSize = CGSizeMake(width * 2, height)
        superview.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        
        mine = ActivityHomeMineListController()
        addChildViewController(mine)
        let mineView = mine.view
        board.addSubview(mineView)
        mineView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(board)
        }
        mine.home = self
        mine.didMoveToParentViewController(self)
//        
//        nearBy = ActivityNearByController()
//        let nearByView = nearBy.view
//        board.addSubview(nearByView)
//        nearByView.snp_makeConstraints { (make) -> Void in
//            make.size.equalTo(superview)
//            make.top.equalTo(superview)
//            make.left.equalTo(board)
//        }
//        nearBy.home = self
        
        applied = ActivityAppliedController()
        addChildViewController(applied)
        let appliedView = applied.view
        board.addSubview(appliedView)
        appliedView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(board).offset(width)
        }
        applied.home = self
        applied.didMoveToParentViewController(self)
        
        controllers = [mine, applied]
    }
}
