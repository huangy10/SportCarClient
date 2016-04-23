//
//  Notification.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

class NotificationController: UITableViewController {
    // Pointer to the home controller which you can use to push or present detail controllers
    var messageHome: MessageController?
    
    let data = NotificationDataSource.sharedDataSource
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(NotificationBaseCell.self, forCellReuseIdentifier: NotificationBaseCell.reuseIdentifier())
        tableView.registerClass(NotificationCellAboutActivity.self, forCellReuseIdentifier: NotificationCellAboutActivity.reuseIdentifier())
        tableView.registerClass(NotificationCellWithCoverThumbnail.self, forCellReuseIdentifier: NotificationCellWithCoverThumbnail.reuseIdentifier())
        tableView.separatorColor = UIColor(white: 0.945, alpha: 1)
        data.list = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if data.unreadNum > 0 {
            data.unreadNum = 0
            NSNotificationCenter.defaultCenter().postNotificationName(kNotificationUnreadClearNotification, object: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notification = data.notifications[indexPath.row]
        let messageType = notification.messageType!
        switch messageType{
        case "status_like":
            // 给状态点赞了
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("赞了你的动态")
            cell.cover.kf_setImageWithURL(SFURL(notification.image!)!)
            cell.messageBodyLbl.text = nil
            cell.readDot.hidden = notification.read
            return cell
            
        case "status_comment":
            // One of your status is commented
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("评论了你的动态")
            cell.messageBodyLbl.text = notification.messageBody
            cell.cover.kf_setImageWithURL(notification.imageURL!)
            cell.readDot.hidden = notification.read
            return cell
            
        case "status_comment_replied":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("回复了你")
            cell.messageBodyLbl.text = notification.messageBody
            cell.cover.kf_setImageWithURL(notification.imageURL!)
            cell.readDot.hidden = notification.read
            return cell
        
        case "relation_follow":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationBaseCell.reuseIdentifier(), forIndexPath: indexPath) as! NotificationBaseCell
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("关注了你")
            cell.readDot.hidden = notification.read
            return cell
        
        case "status_inform":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("提到了你")
            cell.cover.kf_setImageWithURL(SFURL(notification.image!)!)
            cell.readDot.hidden = notification.read
            cell.messageBodyLbl.text = nil
            return cell
        
        case "act_applied":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            let act: Activity = try! notification.getRelatedObj()!
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("报名了")
            cell.name2LbL.text = act.name
            cell.inform2Lbl.text = ""
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
        
        case "act_invited":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            let act: Activity = try! notification.getRelatedObj()!
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("邀请你参加")
            cell.name2LbL.text = act.name
            cell.inform2Lbl.text = ""
            cell.closeOperation = notification.checked
            cell.doneLbl.text = notification.flag ? LS("已确认") : LS("已拒绝")
            cell.onAgreeBtnPressed = { [weak self] _ in
                let requester = ActivityRequester.requester
                requester.activityOperation(act.ssidString, targetUserID: "", opType: "invite_accepted", onSuccess: { (json) -> () in
                    cell.closeOperation = true
                    }, onError: { (code) -> () in
                        self?.showToast(LS("无法连接到服务器"))
                })
            }
            cell.onDenyBtnPressed = { [weak self] _ in
                let requester = ActivityRequester.requester
                requester.activityOperation(act.ssidString, targetUserID: "", opType: "invite_accepted", onSuccess: { (json) -> () in
                    cell.closeOperation = true
                    }, onError: { (code) -> () in
                        self?.showToast(LS("无法连接到服务器"))
                })
            }
            cell.readDot.hidden = notification.read
            return cell
            
        case "act_denied":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            let act: Activity = try! notification.getRelatedObj()!
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = ""
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("你报名的")
            cell.name2LbL.text = act.name
            cell.inform2Lbl.text = LS("被发起者拒绝了")
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
            
        case "act_invitation_agreed":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user?.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("接受了你的邀请")
            cell.name2LbL.text = ""
            cell.inform2Lbl.text = ""
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
            
        default:
            assertionFailure()
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let notification = data.notifications[indexPath.row]
        let messageType = notification.messageType!
        switch messageType {
        case "status_like", "relation_follow", "status_inform", "act_applied", "act_denied", "act_invitation_accepted":
            return 75
        case "status_comment", "status_comment_replied":
            let messageBody = notification.messageBody ?? ""
            return 90 + messageBody.sizeWithFont(UIFont.systemFontOfSize(14, weight: UIFontWeightLight), boundingSize: CGSizeMake(NotificationCellWithCoverThumbnail.messageBodyLblMaxWidth, CGFloat.max)).height
        case "act_invited":
            return 93.5
//            if notification.checked {
//                return 75
//            } else {
//                return 93.5
//            }
        default:
            return 90
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = data.notifications[indexPath.row]
        if !notification.read {
            ChatRequester.requester.notifMarkRead(notification.ssidString, onSuccess: { (_) -> () in
                }, onError: { (code) -> () in
                    // Do nothing
            })
            notification.read = true
            NotificationDataSource.sharedDataSource.unreadNum -= 1
        }
        let messageType = notification.messageType!
        switch messageType {
        case "status_like", "status_inform":
            let detail = StatusDetailController(status: try! notification.getRelatedObj()!)
            detail.loadAnimated = false
            self.messageHome?.navigationController?.pushViewController(detail, animated: true)
            
        case "status_comment", "status_comment_replied":
            let relatedStatusComment: StatusComment = try! notification.getRelatedObj()!
            let relatedStatus = relatedStatusComment.status
            let detail = StatusDetailController(status: relatedStatus)
            detail.loadAnimated = false
            self.messageHome?.navigationController?.pushViewController(detail, animated: true)
            
        case "relation_follow":
            let detail = PersonOtherController(user: notification.user!)
            self.messageHome?.navigationController?.pushViewController(detail, animated: true)
            
        case "act_applied", "act_invited", "act_denied", "act_invitation_agreed":
            let detail = ActivityDetailController(act: try! notification.getRelatedObj()!)
            self.messageHome?.navigationController?.pushViewController(detail, animated: true)
            
        default:
            break
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            data.getMore()
        }
    }
    
}
