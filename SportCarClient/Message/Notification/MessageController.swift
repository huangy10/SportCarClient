//
//  NotificationController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class MessageController: UIViewController {
    
    var homeDelegate: HomeDelegate?
    
    var board: UIScrollView!
    
    var titleNotifBtn: UIButton!
    var titleChatBtn: UIButton!
    var titleBtnIcon: UIImageView!
    
    var chatList: ChatListController!
    var notificationList: NotificationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()

        board = UIScrollView()
        board.pagingEnabled = true
        board.scrollEnabled = false
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        board.contentSize = CGSizeMake(screenWidth * 2, screenHeight)
        superview.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        
        chatList = ChatListController()
        board.addSubview(chatList.view)
        chatList.messageController = self
        chatList.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(screenWidth)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(screenWidth)
        }
        ChatRecordDataSource.sharedDataSource.listCtrl = chatList
        
        notificationList = NotificationController()
        board.addSubview(notificationList.view)
        notificationList.messageHome = self
        notificationList.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(screenWidth)
        }
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.titleView = barTitleView()
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 15, 13.5)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func barTitleView() -> UIView? {
        let container = UIView()
        let barHeight = self.navigationController!.navigationBar.frame.size.height
        let containerWidth = self.view.frame.width * 0.6
        container.frame = CGRectMake(0, 0, containerWidth, barHeight)
        //
        titleNotifBtn = UIButton()
        titleNotifBtn.setTitle(LS("通知"), forState: .Normal)
        titleNotifBtn.setTitleColor(kBarBgColor, forState: .Normal)
        titleNotifBtn.titleLabel?.font = kBarTextFont
        container.addSubview(titleNotifBtn)
        titleNotifBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp_centerX).offset(-8)
        }
        titleNotifBtn.tag = 0
        titleNotifBtn.addTarget(self, action: "titleBtnPressed:", forControlEvents: .TouchUpInside)
        //
        titleChatBtn = UIButton()
        titleChatBtn.setTitle(LS("聊天"), forState: .Normal)
        titleChatBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleChatBtn.titleLabel?.font = kBarTextFont
        container.addSubview(titleChatBtn)
        titleChatBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp_centerX).offset(8)
        }
        titleChatBtn.tag = 1
        titleChatBtn.addTarget(self, action: "titleBtnPressed:", forControlEvents: .TouchUpInside)
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon)
        container.sendSubviewToBack(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(titleNotifBtn)
        }
        return container
    }
    
    func navRightBtnPressed() {
        chatList.navRightBtnPressed()
    }
    
    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
        homeDelegate?.backToHome(nil, screenShot: self.getScreenShotBlurred(false))
    }
    
    func titleBtnPressed(sender: UIButton) {
        if sender.tag == 1 {
            // 按下了聊天按钮
            board.setContentOffset(CGPointMake(board.frame.width, 0), animated: true)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleChatBtn)
            })
            titleChatBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleNotifBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }else {
            board.setContentOffset(CGPoint.zero, animated: true)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleNotifBtn)
            })
            titleNotifBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleChatBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }

    }
    
}