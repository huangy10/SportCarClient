//
//  NotificationModelManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AlecrimCoreData
import CoreData
import SwiftyJSON


class NotificationModelManager: MainManager {
    private static let _sharedNotificationModelManager = NotificationModelManager()
    
    override var workQueue: dispatch_queue_t {
        if _workQueue == nil {
            _workQueue = dispatch_queue_create("notification_update", DISPATCH_QUEUE_SERIAL)
        }
        return _workQueue!
    }
    
    override class var sharedManager: MainManager {
        return _sharedNotificationModelManager
    }
    
    private var notifContext: DataContext!
    
    override var hostUser: User? {
        if _hostUser == nil {
            _hostUser = MainManager.sharedManager.hostUser
        }
        if _hostUser?.managedObjectContext != getOperationContext() {
            _hostUser = _hostUser?.toContext(getOperationContext()) as? User
        }
        return _hostUser
    }
    
    override var hostUserID: Int32? {
        return MainManager.sharedManager.hostUserID
    }
    
    override init () {
        super.init()
        notifContext = DataContext(parentDataContext: mainContext)
    }
    
    override func getOperationContext() -> DataContext {
        return notifContext
    }
    
    override func save() throws {
        dispatch_async(workQueue) { () -> Void in
            try! super.save()
        }
    }
}