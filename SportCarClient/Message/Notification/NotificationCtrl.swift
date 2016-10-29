//
//  Notification.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

protocol NotificationDataSource: class {
    func numberOfNotifications() -> Int
    
    func notificationAt(_ index: Int) -> Notification
    
    func markNotificationAsReadAt(_ index: Int)
}

class NotificationController: UITableViewController, NotificationCellDelegate, LoadingProtocol {
    internal var delayWorkItem: DispatchWorkItem?
    
    var data: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = UIColor(white: 0.945, alpha: 1)
        MessageManager.defaultManager.enterNotificationList(self)
    }
    
    deinit {
        MessageManager.defaultManager.leaveNotificationList()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MessageManager.defaultManager.unreadNotifNum = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = data[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationCell
        cell.delegate = self
        cell.setData(
            notification.user!.avatarURL!,
            date: notification.createdAt!,
            read: notification.read,
            titleContents: notification.makeDisplayTitlePhrases(),
            coverURL: notification.imageURL,
            detailDescription: notification.messageBody ?? "",
            checked: notification.checked,
            flag: notification.flag,
            displayMode: notification.getDisplayMode()
        )
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notification = data[(indexPath as NSIndexPath).row]
        return NotificationCell.cellHeightForTitle(notification.makeDisplayTitlePhrases(), detailDescription: notification.messageBody ?? "", displayMode: notification.getDisplayMode())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = data[(indexPath as NSIndexPath).row]
        if !notification.read {
            _ = NotificationRequester.sharedInstance.notifMarkRead(notification.ssidString, onSuccess: { (json) in
                //
                notification.read = true
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }, onError: { (code) in
                
            })
        }
        parent?.navigationController?.pushViewController(getDetailController(forRow: (indexPath as NSIndexPath).row), animated: true)
    }
    
    lazy var detailControllerMap: [String: (Notification)->UIViewController] = {
        func user(_ notification: Notification) -> UIViewController {
            let user = notification.user!
            if user.isHost {
                return PersonBasicController(user: user)
            } else {
                return PersonOtherController(user: user)
            }
        }
        
        func status(_ notification: Notification) -> UIViewController {
            let status = try! notification.getRelatedObj()! as Status
            let detail = StatusDetailController(status: status)
            detail.loadAnimated = false
            return detail
        }
        
        func statusComment(_ notification: Notification) -> UIViewController {
            let status =  (try! notification.getRelatedObj()! as StatusComment).status
            let detail = StatusDetailController(status: status)
            detail.loadAnimated = false
            return detail
        }

        
        func activity(_ notification: Notification) -> UIViewController {
            let act = try! notification.getRelatedObj()! as Activity
            return ActivityDetailController(act: act)
        }
        
        func activityComment(_ notification: Notification) -> UIViewController {
            let act = (try! notification.getRelatedObj()! as ActivityComment).act
            return ActivityDetailController(act: act)
        }
        
        func club(_ notification: Notification) -> UIViewController {
            let club: Club = try! notification.getRelatedObj()!
            if club.attended {
//                if club.founderUser!.isHost {
//                    let detail = GroupChatSettingHostController(targetClub: club)
//                    return detail
//                } else {
//                    let detail = GroupChatSettingController(targetClub: club)
//                    return detail
//                }
                let chatRoom  = ChatRoomController()
                chatRoom.targetClub = club
                chatRoom.chatCreated = false
                return chatRoom
            } else {
                let detail = ClubBriefInfoController()
                detail.targetClub = club
                return detail
            }
        }
        
        return ["User": user, "Status": status, "StatusComment" : statusComment, "Activity": activity, "ActivityComment": activityComment, "ActivityJoin": activity, "Club": club, "ClubJoining": club]
    }()
    
    func getDetailController(forRow row: Int) -> UIViewController {
        let notification = data[row]
        let messageType = notification.simplifiedMessageType
        let senderClassKey = messageType.split(delimiter: ":")[0]
        let detail = detailControllerMap[senderClassKey]!(notification)
        return detail
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            MessageManager.defaultManager.loadHistory(self, onFinish: { (notifs) in
                guard let notifs = notifs else {
                    return
                }
                self.data.append(contentsOf: notifs)
                self.tableView.reloadData()
            })
        }
    }
    
    func notificationCellAvatarBtnPressed(atCell cell: NotificationCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let notification = data[(indexPath as NSIndexPath).row]
            if let user = notification.user, let nav = parent?.navigationController {
                if user.isHost {
                    let detail = PersonBasicController(user: user)
                    nav.pushViewController(detail, animated: true)
                } else {
                    let detail = PersonOtherController(user: user)
                    nav.pushViewController(detail, animated: true)
                }
            } else {
                assertionFailure()
            }
        } else {
            assertionFailure()
        }
    }
    
    func notificationCellOperationInvoked(atCell cell: NotificationCell, operationType: NotificationCell.OperationType) {
        if let indexPath = tableView.indexPath(for: cell) {
            let notification = data[(indexPath as NSIndexPath).row]
            let messageType = notification.simplifiedMessageType
            
            switch messageType {
            case  "ActivityJoin:invited":
                let opType = "invite_\(operationType.rawValue)"
                let activity = try! notification.getRelatedObj()! as Activity
                lp_start()
                _ = ActivityRequester.sharedInstance.activityOperation(activity.ssidString, targetUserID: notification.user!.ssidString, opType: opType, onSuccess: { (json) in
                    notification.flag = operationType == .Agree
                    notification.checked = true
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.lp_stop()
                    }, onError: { (code) in
                        self.lp_stop()
                        self.showToast(LS("操作失败"))
                })
            case "ClubJoining:apply":
                let opType = "club_apply_\(operationType.rawValue)"
                let club = try! notification.getRelatedObj()! as Club
                lp_start()
                _ = ClubRequester.sharedInstance.clubOperation(club.ssidString, targetUserID: notification.user!.ssidString, opType: opType, onSuccess: { (json) in
                    notification.checked = true
                    notification.flag = operationType == .Agree
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.lp_stop()
                    }, onError: { (code) in
                        self.lp_stop()
                        self.showToast(LS("操作失败"))
                })
            default:
                break
            }
        }
    }
    
}
