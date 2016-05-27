//
//  NotificationController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

extension UILabel {
    func setUnreadNum(num: Int) {
        if num <= 99 {
            text = "\(num)"
        } else {
            text = "99+"
        }
        hidden = num == 0
    }
}

class MessageController: UIViewController {
    
    weak var homeDelegate: HomeDelegate?
    
    var board: UIScrollView!
    
    var titleNotifLbl: UILabel!
    var notifUnreadLbl: UILabel!
    var titleChatLbl: UILabel!
    var chatUnreadLbl: UILabel!
    var titleBtnIcon: UIImageView!
    
    var chatList: RosterController!
    var notificationList: NotificationController!
    
    private var _curTag = 0
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUnreadNumChanged(_:)), name: kUnreadNumberDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if _curTag == 0 {
            notificationList.viewWillAppear(animated)
        } else {
            chatList.viewWillAppear(animated)
        }
        notifUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadNotifNum)
        chatUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadChatNum)
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
        
        chatList = RosterController()
        board.addSubview(chatList.view)
        chatList.messageController = self
        chatList.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(screenWidth)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(screenWidth)
        }
//        ChatRecordDataSource.sharedDataSource.listCtrl = chatList
        
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
        navLeftBtn.addTarget(self, action: #selector(MessageController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 18, 18)
        navRightBtn.addTarget(self, action: #selector(MessageController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func barTitleView() -> UIView? {
        let container = UIView()
        let barHeight = self.navigationController!.navigationBar.frame.size.height
        let containerWidth = self.view.frame.width * 0.6
        container.frame = CGRectMake(0, 0, containerWidth, barHeight)
        //
        let titleNotifBtn = UIButton()
        container.addSubview(titleNotifBtn)
        titleNotifBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp_centerX)
        }
        titleNotifLbl = titleNotifBtn.addSubview(UILabel)
            .config(14, textColor: kTextBlack, textAlignment: .Center, text: LS("通知"))
            .layout({ (make) in
                make.center.equalTo(titleNotifBtn)
                make.size.equalTo(LS(" 通知 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        notifUnreadLbl = container.addSubview(UILabel).config(9, textColor: UIColor.whiteColor(), textAlignment: .Center).config(kHighlightedRedTextColor).layout({ (make) in
            make.left.equalTo(titleNotifBtn)
            make.top.equalTo(titleNotifBtn)
            make.size.equalTo(18)
        })
        notifUnreadLbl.layer.cornerRadius = 9
        notifUnreadLbl.clipsToBounds = true
        titleNotifBtn.tag = 0
        titleNotifBtn.addTarget(self, action: #selector(MessageController.titleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        //
        let titleChatBtn = UIButton()
        container.addSubview(titleChatBtn)
        titleChatBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp_centerX)
        }
        titleChatBtn.tag = 1
        titleChatBtn.addTarget(self, action: #selector(MessageController.titleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        titleChatLbl = titleChatBtn.addSubview(UILabel)
            .config(14, textColor: kTextGray, textAlignment: .Center, text: LS("聊天"))
            .layout({ (make) in
                make.center.equalTo(titleChatBtn)
                make.size.equalTo(LS(" 聊天 ").sizeWithFont(kBarTextFont, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)))
            })
        chatUnreadLbl = container.addSubview(UILabel)
            .config(9, textColor: UIColor.whiteColor(), textAlignment: .Center)
            .config(kHighlightedRedTextColor)
            .layout({ (make) in
            make.right.equalTo(titleChatBtn)
            make.top.equalTo(titleChatBtn)
            make.size.equalTo(18)
        })
        chatUnreadLbl.layer.cornerRadius = 9
        chatUnreadLbl.clipsToBounds = true
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleBtnIcon)
        container.sendSubviewToBack(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(container)
            make.left.equalTo(titleNotifLbl)
            make.right.equalTo(titleNotifLbl)
            make.height.equalTo(2.5)
        }
        return container
    }
    
    func navRightBtnPressed() {
        chatList.navRightBtnPressed()
    }
    
    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
        homeDelegate?.backToHome(nil)
    }
    
    func titleBtnPressed(sender: UIButton) {
        if sender.tag == _curTag {
            return
        }
        if sender.tag == 1 {
            // 按下了聊天按钮
            chatList.viewWillAppear(true)
            notificationList.viewWillDisappear(true)
            board.setContentOffset(CGPointMake(board.frame.width, 0), animated: true)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(titleBtnIcon.superview!)
                make.left.equalTo(titleChatLbl)
                make.right.equalTo(titleChatLbl)
                make.height.equalTo(2.5)
            })
            titleChatLbl.textColor = kTextBlack
            titleNotifLbl.textColor = kTextGray
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }else {
            chatList.viewWillDisappear(true)
            notificationList.viewWillAppear(true)
            board.setContentOffset(CGPoint.zero, animated: true)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(titleBtnIcon.superview!)
                make.left.equalTo(titleNotifLbl)
                make.right.equalTo(titleNotifLbl)
                make.height.equalTo(2.5)
            })
            titleChatLbl.textColor = kTextGray
            titleNotifLbl.textColor = kTextBlack
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }
        _curTag = sender.tag
    }
    
    func onUnreadNumChanged(notification: NSNotification) {
        let name = notification.name
        if name == kUnreadNumberDidChangeNotification {
            dispatch_async(dispatch_get_main_queue(), { 
                self.notifUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadNotifNum)
                self.chatUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadChatNum)
            })
            
        }
    }
    
}