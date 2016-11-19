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

class MessageController: TaggedContainer {
    
    var chatList: RosterController = RosterController()
    var notificationList: NotificationController = NotificationController()
    
    var notifUnreadLbl: UILabel!
    var chatUnreadLbl: UILabel!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUnreadLbls()
        NotificationCenter.default.addObserver(self, selector: #selector(onUnreadNumChanged(_:)), name: NSNotification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notifUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadNotifNum)
        chatUnreadLbl.setUnreadNum(MessageManager.defaultManager.unreadChatNum)
    }
    
    func configureUnreadLbls() {
        let container = barTitleIcon.superview!
        notifUnreadLbl = container.addSubview(UILabel.self).config(9, textColor: UIColor.white, textAlignment: .center).config(kHighlightedRedTextColor).layout({ (make) in
            make.left.equalTo(titleLbls[0].superview!)
            make.top.equalTo(titleLbls[0].superview!)
            make.size.equalTo(18)
        })
        notifUnreadLbl.layer.cornerRadius = 9
        notifUnreadLbl.clipsToBounds = true
        
        chatUnreadLbl = container.addSubview(UILabel.self)
            .config(9, textColor: UIColor.white, textAlignment: .center)
            .config(kHighlightedRedTextColor)
            .layout({ (make) in
                make.right.equalTo(titleLbls[1].superview!)
                make.top.equalTo(titleLbls[1].superview!)
                make.size.equalTo(18)
            })
        chatUnreadLbl.layer.cornerRadius = 9
        chatUnreadLbl.clipsToBounds = true

    }
    
    override func numberOfCountrollers() -> Int {
        return 2
    }
    
    override func createArrangedController() -> [UIViewController] {
        return [notificationList, chatList]
    }
    
    override func titleForController(at index: Int) -> String {
        return [LS("通知"), LS("聊天")][index]
    }
    
    override func configureNavRightBtn() {
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), for: .normal)
        navRightBtn.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        navRightBtn.addTarget(self, action: #selector(navRightBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func navRightBtnPressed() {
        chatList.navRightBtnPressed()
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

extension MessageController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push where (fromVC == self && toVC.isKind(of: StatusDetailController.self)):
            let res = StatusCoverPresentAnimation()
            res.delegate = notificationList
            return res
        case .pop where (fromVC.isKind(of: StatusDetailController.self) && toVC == self):
            let res = StatusCoverDismissAnimation()
            res.delegate = notificationList
            return res
        default:
            return nil
        }
    }
}

