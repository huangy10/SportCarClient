//
//  NotificationDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Dollar


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
                try! NotificationModelManager.sharedManager.save()
            }
            ss_sendUnreadNumberDidChangeNotification()
        }
    }
    let requester = ChatRequester.requester
    let privateQueue: dispatch_queue_t
    var started: Bool = false
    var waiter: dispatch_semaphore_t?
    
    override init() {
        privateQueue = requester.notificationQueue
        super.init()
        loadHistoricalNotifications()
        start()
    }
    
    func loadHistoricalNotifications() {
        self.notifications.appendContentsOf(Notification.loadHistoricalList(40))
        self.unreadNum = 0
    }
    
    /**
     Utility function to hanle response from server
     */
    func loadNotificationListFromJSON(json: [JSON]) {
        var updated = false
        for data in json {
            let notification: Notification = try! NotificationModelManager.sharedManager.getOrCreate(data)
            if !notification.read {
                self.unreadNum += 1
            }
            self.notifications.append(notification)
            updated = true
        }
        notifications = $.uniq(notifications, by: { $0.ssid })
        notifications.sortInPlace { (notif1, notif2) -> Bool in
            switch notif1.createdAt!.compare(notif2.createdAt!) {
            case .OrderedDescending:
                return true
            default:
                return false
            }
        }
        if updated {
            try! NotificationModelManager.sharedManager.save()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.list?.tableView.reloadData()
            })
        }
    }
    
    func updateNotification() {
        let threshold = notifications.first()?.createdAt ?? NSDate()
        let opType = notifications.first() != nil ? "latest" : "more"
        let dateFix = notifications.first()?.ssidString ?? ""
        requester.getNotifications(threshold, limit: 10, opType: opType, dateFix: dateFix, onSuccess: { (json) -> () in
            self.loadNotificationListFromJSON(json!.arrayValue)
            var delayTime: dispatch_time_t = DISPATCH_TIME_NOW
            delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
            dispatch_after(delayTime, self.privateQueue, { () -> Void in
                self.updateNotification()
            })
            }) { (code) -> () in
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
        }
    }
    
    func flushAll() {
        try! NotificationModelManager.sharedManager.save()
        notifications.removeAll()
    }
    
    func pause() {
        waiter = dispatch_semaphore_create(0)
        dispatch_async(privateQueue) { () -> Void in
            dispatch_semaphore_wait(self.waiter!, DISPATCH_TIME_FOREVER)
        }
    }
    
    func start() {
        if started {
            if waiter != nil {
                dispatch_semaphore_signal(waiter!)
                waiter = nil
            }
            return
        }
        started = true
        dispatch_async(privateQueue) { () -> Void in
            self.updateNotification()
        }
    }
}
