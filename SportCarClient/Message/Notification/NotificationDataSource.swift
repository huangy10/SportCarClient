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
    let privateQueue: dispatch_queue_t
    var started: Bool = false
    
    override init() {
        privateQueue = requester.notificationQueue
        super.init()
        loadHistoricalNotifications()
        dispatch_async(privateQueue) { () -> Void in
            self.updateNotification()
        }
    }
    
    func loadHistoricalNotifications() {
        self.notifications.appendContentsOf(Notification.objects.historicalList(40))
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
            Notification.objects.saveAll()
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
            var delayTime: dispatch_time_t = DISPATCH_TIME_NOW
            delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
            dispatch_after(delayTime, self.privateQueue, { () -> Void in
                self.updateNotification()
            })
            }) { (code) -> () in
                print(code)
                var delayTime: dispatch_time_t = DISPATCH_TIME_NOW
                delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
                dispatch_after(delayTime, self.privateQueue, { () -> Void in
                    self.updateNotification()
                })
        }
    }
    
    func getMore() {
        let threshold = notifications.last()?.createdAt ?? NSDate()
        requester.getNotifications(threshold, limit: 10, opType: "more", onSuccess: { (json) -> () in
            self.loadNotificationListFromJSON(json!.arrayValue)
            }) { (code) -> () in
                print(code)
        }
    }
}
