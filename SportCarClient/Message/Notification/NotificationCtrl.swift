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
        data.list = self
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
        let messageModel = messageType.split("_").first()!
        let messageDetail = messageType.split("_").last()!
        switch messageModel{
        case "status":
            switch messageDetail {
            case "like":
                // 给状态点赞了
                let cell = tableView.dequeueReusableCellWithIdentifier(NotificationCellWithCoverThumbnail.reuseIdentifier(), forIndexPath: indexPath) as! NotificationCellWithCoverThumbnail
                cell.avatarBtn.kf_setImageWithURL(SFURL(notification.user!.avatarUrl!)!, forState: .Normal)
                cell.nickNameLbl.text = notification.user!.nickName
                cell.dateLbl.text = dateDisplay(notification.createdAt!)
                cell.informLbL.text = LS("赞了你的动态")
                cell.cover.kf_setImageWithURL(SFURL(notification.image!)!)
                return cell
            default:
                assertionFailure()
                return UITableViewCell()
            }
        default:
            assertionFailure()
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            data.getMore()
        }
    }
    
}
