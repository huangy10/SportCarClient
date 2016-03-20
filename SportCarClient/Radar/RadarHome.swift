//
//  RadarHome.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class RadarHomeController: UIViewController, FFSelectDelegate, GroupChatSetupDelegate{
    weak var homeDelegate: HomeDelegate?
    
    var driver: RadarDriverMapController!
    var club: ClubDiscoverController!
    
    var board: UIScrollView!
    var titleBtnIcon: UIImageView!
    var titleDriverBtn: UIButton!
    var titleClubBtn: UIButton!
    
    var releaseBoard: UIView!
    var navRightBtn: UIButton!
    var navRightIcon: UIImageView!
    
    var curTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    deinit {
        print("deinit radar home")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if navRightBtn.tag == 0 {
            driver.viewWillAppear(animated)
        } else {
            club.viewWillAppear(animated)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if navRightBtn.tag == 0 {
            driver.viewWillDisappear(animated)
        } else {
            club.viewWillDisappear(animated)
        }
    }
    
    func navSettings() {
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 15, 13.5)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        navRightBtn = UIButton()
        navRightBtn.tag = 0
        navRightIcon = UIImageView(image: UIImage(named: "status_add_btn_white"))
        navRightBtn.addSubview(navRightIcon)
        navRightIcon.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        //
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView()
        container.frame = CGRectMake(0, 0, containerWidth, barHeight)
        container.backgroundColor = UIColor.clearColor()
        //
        titleDriverBtn = UIButton()
        titleDriverBtn.tag = 0
        titleDriverBtn.setTitle(LS("车主"), forState: .Normal)
        titleDriverBtn.setTitleColor(kBarBgColor, forState: .Normal)
        titleDriverBtn.titleLabel?.font = kBarTextFont
        titleDriverBtn.addTarget(self, action: "navTitleBtnPressed:", forControlEvents: .TouchUpInside)
        container.addSubview(titleDriverBtn)
        titleDriverBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.right.equalTo(container.snp_centerX).offset(-8)
            make.centerY.equalTo(container)
        }
        //
        titleClubBtn = UIButton()
        titleClubBtn.tag = 1
        titleClubBtn.setTitle(LS("俱乐部"), forState: .Normal)
        titleClubBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleClubBtn.titleLabel?.font = kBarTextFont
        titleClubBtn.addTarget(self, action: "navTitleBtnPressed:", forControlEvents: .TouchUpInside)
        container.addSubview(titleClubBtn)
        titleClubBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.left.equalTo(container.snp_centerX).offset(8)
            make.centerY.equalTo(container)
        }
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(titleDriverBtn)
        }
        container.sendSubviewToBack(titleBtnIcon)
        //
        self.navigationItem.titleView = container
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil, screenShot: self.getScreenShotBlurred(false))
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func navRightBtnPressed() {
        let superview = self.view
        let trans: CATransform3D
        if navRightBtn.tag == 1 {
            releaseBoard.snp_remakeConstraints { (make) -> Void in
                make.bottom.equalTo(superview.snp_top)
                make.right.equalTo(superview)
                make.width.equalTo(125)
                make.height.equalTo(150)
            }
            trans = CATransform3DIdentity
            navRightBtn.tag = 0
        }else {
            releaseBoard.snp_remakeConstraints { (make) -> Void in
                make.top.equalTo(superview)
                make.right.equalTo(superview)
                make.width.equalTo(125)
                make.height.equalTo(150)
            }
            trans = CATransform3DMakeRotation(CGFloat(M_PI / 4), 0, 0, 1.0)
            navRightBtn.tag = 1
        }
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
            self.navRightIcon.layer.transform = trans
        }
    }
    
    func navTitleBtnPressed(sender: UIButton) {
        if sender.tag == curTag {
            return
        }
        
        if sender.tag == 0 {
            board.setContentOffset(CGPointZero, animated: true)
            titleDriverBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleClubBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleDriverBtn)
            })
        }else {
            board.setContentOffset(CGPointMake(self.view.frame.width, 0), animated: true)
            titleDriverBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            titleClubBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleClubBtn)
            })
        }
        curTag = sender.tag
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.titleBtnIcon.superview?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func createSubviews(){
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        let width = self.view.frame.width
        board = UIScrollView()
        board.pagingEnabled = true
        board.scrollEnabled = false
        board.contentSize = CGSizeMake(width * 2, 0)
        superview.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        driver = RadarDriverMapController()
        driver.radarHome = self
        board.addSubview(driver.view)
        driver.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
        //
        club = ClubDiscoverController()
        club.radarHome = self
        board.addSubview(club.view)
        club.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(width)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
        
        createReleaseBoard()
    }
    
    func createReleaseBoard() {
        var superview = self.view
        
        releaseBoard = UIView()
        releaseBoard.backgroundColor = UIColor.whiteColor()
        superview.addSubview(releaseBoard)
        releaseBoard.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview.snp_top)
            make.right.equalTo(superview)
            make.width.equalTo(125)
            make.height.equalTo(150)
        }
        superview = releaseBoard
        let releaseStatus = UIButton()
        releaseStatus.tag = 0
        releaseStatus.addTarget(self, action: "releaseBtnPressed:", forControlEvents: .TouchUpInside)
        releaseStatus.setTitle(LS("发布动态"), forState: .Normal)
        releaseStatus.setTitleColor(UIColor.blackColor(), forState: .Normal)
        releaseStatus.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(releaseStatus)
        releaseStatus.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(superview).dividedBy(3)
            make.width.equalTo(90)
        }
        let releaseStatusIcon = UIImageView(image: UIImage(named: "radar_new_status"))
        superview.addSubview(releaseStatusIcon)
        releaseStatusIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(releaseStatus)
            make.right.equalTo(releaseStatus.snp_left)
            make.size.equalTo(17)
        }
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(releaseStatus)
            make.height.equalTo(0.5)
        }
        let addChat = UIButton()
        addChat.tag = 1
        addChat.addTarget(self, action: "releaseBtnPressed:", forControlEvents: .TouchUpInside)
        addChat.setTitleColor(UIColor.blackColor(), forState: .Normal)
        addChat.setTitle(LS("新建聊天"), forState: .Normal)
        addChat.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(addChat)
        addChat.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(releaseStatus.snp_bottom)
            make.width.equalTo(releaseStatus)
            make.height.equalTo(releaseStatus)
        }
        let addChatIcon = UIImageView(image: UIImage(named: "radar_new_chat"))
        superview.addSubview(addChatIcon)
        addChatIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(addChat)
            make.right.equalTo(addChat.snp_left)
            make.size.equalTo(19)
        }
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(addChat)
            make.height.equalTo(0.5)
        }
        let startActivity = UIButton()
        startActivity.tag = 2
        startActivity.addTarget(self, action: "releaseBtnPressed:", forControlEvents: .TouchUpInside)
        startActivity.setTitle(LS("发起活动"), forState: .Normal)
        startActivity.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startActivity.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(startActivity)
        startActivity.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(addChat.snp_bottom)
            make.width.equalTo(addChat)
            make.bottom.equalTo(superview)
        }
        let startActivityIcon = UIImageView(image: UIImage(named: "radar_new_activity"))
        superview.addSubview(startActivityIcon)
        startActivityIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(startActivity.snp_left)
            make.centerY.equalTo(startActivity)
            make.size.equalTo(19)
        }
    }
}

// MARK: - Popover
extension RadarHomeController {
    
    func releaseBtnPressed(sender: UIButton) {
        switch sender.tag {
        case 0:
            let release = StatusReleaseController()
            release.pp_presentWithWrapperFromController(self)
//            let wrapper = BlackBarNavigationController(rootViewController: release)
//            self.presentViewController(wrapper, animated: true, completion: nil)
        case 1:
            let selector = FFSelectController()
            selector.delegate = self
            let nav = BlackBarNavigationController(rootViewController: selector)
            self.presentViewController(nav, animated: true, completion: nil)
        case 2:
            let detail = ActivityReleasePresentableController()
            detail.presentFrom(self)
        default:
            break
        }
        self.navRightBtnPressed()
    }
    
    func userSelectCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if users.count == 1 {
            let room = ChatRoomController()
            room.targetUser = users.first
            self.navigationController?.pushViewController(room, animated: true)
        }else if users.count > 1 {
            let detail = GroupChatSetupController()
            detail.delegate = self
            detail.users = users
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func groupChatSetupControllerDidSuccessCreatingClub(newClub: Club) {
        // 群聊创建成功，打开聊天窗口
        self.navigationController?.popViewControllerAnimated(true)
        // Ensure that the datasource is started
        ChatRecordDataSource.sharedDataSource.start()
        let chatRoom = ChatRoomController()
        chatRoom.targetClub = newClub
        self.navigationController?.pushViewController(chatRoom, animated: true)

    }
}
