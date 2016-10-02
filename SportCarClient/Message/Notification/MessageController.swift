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
    func setUnreadNum(_ num: Int) {
        if num <= 99 {
            text = "\(num)"
        } else {
            text = "99+"
        }
        isHidden = num == 0
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
    
    fileprivate var _curTag = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
        NotificationCenter.default.addObserver(self, selector: #selector(onUnreadNumChanged(_:)), name: NSNotification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        if _curTag == 0 {
//            notificationList.viewWillAppear(animated)
//        } else {
//            chatList.viewWillAppear(animated)
//        }
        notifUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadNotifNum)
        chatUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadChatNum)
    }
    
    func createSubviews() {
        let superview = self.view!
        superview.backgroundColor = UIColor.white

        board = UIScrollView()
        board.isPagingEnabled = true
        board.isScrollEnabled = false
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        board.contentSize = CGSize(width: screenWidth * 2, height: screenHeight)
        superview.addSubview(board)
        board.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        
        chatList = RosterController()
        chatList.willMove(toParentViewController: self)
        addChildViewController(chatList)
        board.addSubview(chatList.view)
        chatList.messageController = self
        chatList.view.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(screenWidth)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(screenWidth)
        }
        chatList.didMove(toParentViewController: self)
        
//        ChatRecordDataSource.sharedDataSource.listCtrl = chatList
        
        notificationList = NotificationController()
        notificationList.willMove(toParentViewController: self)
        addChildViewController(notificationList)
        board.addSubview(notificationList.view)
        notificationList.messageHome = self
        notificationList.view.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(board)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(screenWidth)
        }
        notificationList.didMove(toParentViewController: self)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.titleView = barTitleView()
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), for: UIControlState())
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 13.5)
        navLeftBtn.addTarget(self, action: #selector(MessageController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), for: UIControlState())
        navRightBtn.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        navRightBtn.addTarget(self, action: #selector(MessageController.navRightBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func barTitleView() -> UIView? {
        let container = UIView()
        let barHeight = self.navigationController!.navigationBar.frame.size.height
        let containerWidth = self.view.frame.width * 0.6
        container.frame = CGRect(x: 0, y: 0, width: containerWidth, height: barHeight)
        //
        let titleNotifBtn = UIButton()
        container.addSubview(titleNotifBtn)
        titleNotifBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp.centerX)
        }
        titleNotifLbl = titleNotifBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightBold, textColor: kTextBlack, textAlignment: .center, text: LS("通知"))
            .layout({ (make) in
                make.center.equalTo(titleNotifBtn)
                make.size.equalTo(LS(" 通知 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        notifUnreadLbl = container.addSubview(UILabel.self).config(9, textColor: UIColor.white, textAlignment: .center).config(kHighlightedRedTextColor).layout({ (make) in
            make.left.equalTo(titleNotifBtn)
            make.top.equalTo(titleNotifBtn)
            make.size.equalTo(18)
        })
        notifUnreadLbl.layer.cornerRadius = 9
        notifUnreadLbl.clipsToBounds = true
        titleNotifBtn.tag = 0
        titleNotifBtn.addTarget(self, action: #selector(MessageController.titleBtnPressed(_:)), for: .touchUpInside)
        //
        let titleChatBtn = UIButton()
        container.addSubview(titleChatBtn)
        titleChatBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp.centerX)
        }
        titleChatBtn.tag = 1
        titleChatBtn.addTarget(self, action: #selector(MessageController.titleBtnPressed(_:)), for: .touchUpInside)
        titleChatLbl = titleChatBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightBold, textColor: kTextGray, textAlignment: .center, text: LS("聊天"))
            .layout({ (make) in
                make.center.equalTo(titleChatBtn)
                make.size.equalTo(LS(" 聊天 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        chatUnreadLbl = container.addSubview(UILabel.self)
            .config(9, textColor: UIColor.white, textAlignment: .center)
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
        container.sendSubview(toBack: titleBtnIcon)
        titleBtnIcon.snp.makeConstraints { (make) -> Void in
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
    
    func titleBtnPressed(_ sender: UIButton) {
        if sender.tag == _curTag {
            return
        }
        if sender.tag == 1 {
            // 按下了聊天按钮
            chatList.viewWillAppear(true)
            notificationList.viewWillDisappear(true)
            board.setContentOffset(CGPoint(x: board.frame.width, y: 0), animated: true)
            titleBtnIcon.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(titleBtnIcon.superview!)
                make.left.equalTo(titleChatLbl)
                make.right.equalTo(titleChatLbl)
                make.height.equalTo(2.5)
            })
            titleChatLbl.textColor = kTextBlack
            titleNotifLbl.textColor = kTextGray
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }else {
            chatList.viewWillDisappear(true)
            notificationList.viewWillAppear(true)
            board.setContentOffset(CGPoint.zero, animated: true)
            titleBtnIcon.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(titleBtnIcon.superview!)
                make.left.equalTo(titleNotifLbl)
                make.right.equalTo(titleNotifLbl)
                make.height.equalTo(2.5)
            })
            titleChatLbl.textColor = kTextGray
            titleNotifLbl.textColor = kTextBlack
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon.superview!.layoutIfNeeded()
                }, completion: nil)
        }
        _curTag = sender.tag
    }
    
    func onUnreadNumChanged(_ notification: Foundation.Notification) {
        let name = notification.name.rawValue
        if name == kUnreadNumberDidChangeNotification {
            DispatchQueue.main.async(execute: { 
                self.notifUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadNotifNum)
                self.chatUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadChatNum)
            })
            
        }
    }
    
}
