//
//  NotificationDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class NotificationDataSource: NSObject {
    
    static let sharedDataSource = NotificationDataSource()
    
    weak var list: UITableViewController?
    
    var notifications: [Notification] = []
    var unreadNum: Int = 0 {
        didSet {
            if unreadNum == 0 {
                notifications.each({ (notification) -> () in
                    notification.read = true
                })
                Notification.objects.saveAll()
            }
        }
    }
    let requester = ChatRequester.requester
    
    var heartBeat: NSTimer!
    var started: Bool = false
    
    override init() {
        super.init()
        heartBeat = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "updateNotification", userInfo: nil, repeats: true)
    }
    
    /**
     Utility function to hanle response from server
     */
    func loadNotificationListFromJSON(json: [JSON]) {
        var updated = false
        for data in json {
            let notification = Notification.objects.getOrCreate(data)
            self.notifications.append(notification!)
            updated = true
        }
        if updated {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.list?.tableView.reloadData()
            })
        }
    }
    
    func updateNotification() {
        let threshold = notifications.first()?.createdAt ?? NSDate()
        let opType = notifications.first() != nil ? "latest" : "more"
        let dateFix = notifications.first()?.notificationID ?? ""
        requester.getNotifications(threshold, limit: 10, opType: opType, dateFix: dateFix, onSuccess: { (json) -> () in
            self.loadNotificationListFromJSON(json!.arrayValue)
            }) { (code) -> () in
                print(code)
        }
    }
    
    func getMore() {
        let threshold = notifications.first()?.createdAt ?? NSDate()
        requester.getNotifications(threshold, limit: 10, opType: "more", onSuccess: { (json) -> () in
            self.loadNotificationListFromJSON(json!.arrayValue)
            }) { (code) -> () in
                print(code)
        }
    }
}
