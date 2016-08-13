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
    
    var data: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(NotificationBaseCell.self, forCellReuseIdentifier: NotificationBaseCell.reuseIdentifier())
        tableView.registerClass(NotificationCellAboutActivity.self, forCellReuseIdentifier: NotificationCellAboutActivity.reuseIdentifier())
        tableView.registerClass(NotificationCellWithCoverThumbnail.self, forCellReuseIdentifier: NotificationCellWithCoverThumbnail.reuseIdentifier())
        tableView.separatorColor = UIColor(white: 0.945, alpha: 1)
        MessageManager.defaultManager.enterNotificationList(self)
    }
    
    deinit {
        MessageManager.defaultManager.leaveNotificationList()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MessageManager.defaultManager.unreadNotifNum = 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notification = data[indexPath.row]
        let messageType = notification.messageType!
        switch messageType{
        case "status_like":
            // 给状态点赞了
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
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
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
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
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("关注了你")
            cell.readDot.hidden = notification.read
            return cell
        
        case "status_inform":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
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
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
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
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user!.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("邀请你参加")
            cell.name2LbL.text = act.name
            cell.inform2Lbl.text = ""
            cell.closeOperation = notification.checked
            cell.doneLbl.text = notification.flag ? LS("已确认") : LS("已拒绝")
            cell.onAgreeBtnPressed = { [weak self] _ in
                let requester = ActivityRequester.sharedInstance
                requester.activityOperation(act.ssidString, targetUserID: "", opType: "invite_accepted", onSuccess: { (json) -> () in
                    notification.flag = true
                    notification.checked = true
                    cell.closeOperation = true
                    cell.doneLbl.text = LS("已确认")
                    }, onError: { (code) -> () in
                        if code == "full" {
                            self?.showToast(LS("活动已报满"))
                        } else {
                            self?.showToast(LS("无法连接到服务器"))
                        }
                })
            }
            cell.onDenyBtnPressed = { [weak self] _ in
                let requester = ActivityRequester.sharedInstance
                requester.activityOperation(act.ssidString, targetUserID: "", opType: "invite_accepted", onSuccess: { (json) -> () in
                    notification.flag = false
                    notification.checked = true
                    cell.closeOperation = true
                    cell.doneLbl.text = LS("已拒绝")
                    }, onError: { (code) -> () in
                        self?.showToast(LS("无法连接到服务器"))
                })
            }
            cell.readDot.hidden = notification.read
            return cell
            
        case "act_denied":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
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
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user?.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("接受了你的邀请")
            cell.name2LbL.text = ""
            cell.inform2Lbl.text = ""
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
        case "club_apply":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(notification.user!.avatarURL!, forState: .Normal)
            cell.nickNameLbl.text = notification.user?.nickName
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("申请加入你的俱乐部")
            let relatedClub: Club = try! notification.getRelatedObj()!
            cell.name2LbL.text = relatedClub.name
            cell.showBtns = true
            cell.readDot.hidden = notification.read
            cell.closeOperation = notification.checked
            cell.doneLbl.text = notification.flag ? LS("已确认") : LS("已拒绝")
            cell.onAgreeBtnPressed = { [weak self] _ in
                guard let sSelf = self else {
                    return
                }
                guard let user = notification.user else {
                    assertionFailure()
                    return
                }
                ClubRequester.sharedInstance.clubOperation(
                    relatedClub.ssidString, targetUserID: user.ssidString, opType: "club_apply_agree", onSuccess: { (json) in
                        cell.closeOperation = true
                        cell.doneLbl.text = LS("已确认")
                        notification.checked = true
                        notification.flag = true
                    }, onError: { (code) in
                        sSelf.showToast(LS("无法连接到服务器"))
                })
            }
            cell.onDenyBtnPressed = { [weak self] _ in
                guard let sSelf = self else {
                    return
                }
                guard let user = notification.user else {
                    assertionFailure()
                    return
                }
                ClubRequester.sharedInstance.clubOperation(
                    relatedClub.ssidString, targetUserID: user.ssidString, opType: "club_apply_deny", onSuccess: { (json) in
                        cell.closeOperation = true
                        cell.doneLbl.text = LS("已拒绝")
                        notification.checked = true
                        notification.flag = false
                    }, onError: { (code) in
                        sSelf.showToast(LS("无法连接到服务器"))
                })
            }
            return cell
            
        case "club_apply_agreed":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            let relatedClub: Club = try! notification.getRelatedObj()!
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(relatedClub.logoURL!, forState: .Normal)
            cell.nickNameLbl.text = relatedClub.name
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("通过了你的申请")
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
            
        case "club_apply_denied":
            let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellAboutActivity.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellAboutActivity
            let relatedClub: Club = try! notification.getRelatedObj()!
            cell.navigationController = messageHome?.navigationController
            cell.notification = notification
            cell.avatarBtn.kf_setImageWithURL(relatedClub.logoURL!, forState: .Normal)
            cell.nickNameLbl.text = relatedClub.name
            cell.dateLbl.text = dateDisplay(notification.createdAt!)
            cell.informLbL.text = LS("拒绝了你的申请")
            cell.showBtns = false
            cell.readDot.hidden = notification.read
            return cell
            
        default:
            print(messageType)
            assertionFailure()
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let notification = data[indexPath.row]
        let messageType = notification.messageType!
        switch messageType {
        case "status_like", "relation_follow", "status_inform", "act_applied", "act_denied", "act_invitation_accepted":
            return 75
        case "status_comment", "status_comment_replied":
            let messageBody = notification.messageBody ?? ""
            return 90 + messageBody.sizeWithFont(UIFont.systemFontOfSize(14, weight: UIFontWeightLight), boundingSize: CGSizeMake(NotificationCellWithCoverThumbnail.messageBodyLblMaxWidth, CGFloat.max)).height
        case "act_invited":
            return 100
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
        let notification = data[indexPath.row]
        if !notification.read {
            NotificationRequester.sharedInstance.notifMarkRead(notification.ssidString, onSuccess: { (json) in
                //
                notification.read = true
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }, onError: { (code) in
                
            })
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
        case "club_apply", "club_apply_agreed", "club_apply_denied":
            let club: Club = try! notification.getRelatedObj()!
            if club.attended {
                if club.founderUser!.isHost {
                    let detail = GroupChatSettingHostController(targetClub: club)
                    messageHome?.navigationController?.pushViewController(detail, animated: true)
                } else {
                    let detail = GroupChatSettingController(targetClub: club)
                    messageHome?.navigationController?.pushViewController(detail, animated: true)
                }
            } else {
                let detail = ClubBriefInfoController()
                detail.targetClub = club
                messageHome?.navigationController?.pushViewController(detail, animated: true)
            }
        default:
            break
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            MessageManager.defaultManager.loadHistory(self, onFinish: { (notifs) in
                guard let notifs = notifs else {
                    return
                }
                self.data.appendContentsOf(notifs)
                self.tableView.reloadData()
            })
        }
    }
    
}
