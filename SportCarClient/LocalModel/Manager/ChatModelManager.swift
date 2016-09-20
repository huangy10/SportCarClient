//
//  ChatModelManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AlecrimCoreData
import CoreData
import SwiftyJSON
import Dollar

class ChatModelManger: MainManager {
    fileprivate static let _sharedClubModelManager = ChatModelManger()
    
    override var workQueue: DispatchQueue {
        if _workQueue == nil {
            _workQueue = DispatchQueue(label: "chat_update", attributes: [])
        }
        return _workQueue!
    }
    
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
    
    override var hostUserIDString: String? {
        return MainManager.sharedManager.hostUserIDString
    }
    
    override class var sharedManager: ChatModelManger {
        return _sharedClubModelManager
    }
    
    fileprivate var chatContext: DataContext!
    
    override init() {
        super.init()
        chatContext = DataContext(parentDataContext: mainContext)
    }
    
    override func getOperationContext() -> DataContext {
        return chatContext
    }
    
    /**
     返回的chats按照createdAt升序
     */
    func loadCachedChats(_ rosterID: Int32, skips: Int, limit: Int) -> [ChatRecord] {
        do {
            // make sure all the changes has been saved, or the skips below will not work properly
            try self.save()
        } catch {
            return []
        }
        let context = self.getOperationContext()
        let chats: [ChatRecord] = context.chatRecords.filter({
            $0.hostSSID == self.hostUserID! &&
            $0.rosterID == rosterID
        }).orderByDescending({$0.createdAt})
            .skip(skips)
            .take(limit)
            .toArray()
            .reversed()
        chats.each { $0.manager = self }
        return chats
    }
    /**
     返回的notifs按照createdAt降序排列
     */
    func loadCachedNotifications(_ skips: Int, limit: Int) -> [Notification] {
        do {
            try self.save()
        } catch {
            return []
        }
        let context = self.getOperationContext()
        let notifs: [Notification] = context.notifications.filter({
            $0.hostSSID == self.hostUserID!
        }).orderByDescending({$0.createdAt})
            .skip(skips)
            .take(limit)
            .toArray()
        notifs.each { $0.manager = self }
        return notifs
    }
    
    override func save() throws {
        if Thread.isMainThread {
            workQueue.async { () -> Void in
                try! self.chatContext.save()
            }
        } else {
            try self.chatContext.save()
        }
    }
}
