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

class ChatModelManger: MainManager {
    private static let _sharedClubModelManager = ChatModelManger()
    private let _workQueue: dispatch_queue_t = dispatch_queue_create("chat_update", DISPATCH_QUEUE_SERIAL)
    
    var workQueue: dispatch_queue_t {
        return _workQueue
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
    
    override class var sharedManager: MainManager {
        return _sharedClubModelManager
    }
    
    private var chatContext: DataContext!
    
    override init() {
        super.init()
        chatContext = DataContext(parentDataContext: mainContext)
    }
    
    override func getOperationContext() -> DataContext {
        return chatContext
    }
    
    override func save() throws {
        dispatch_async(workQueue) { () -> Void in
            try! super.save()
        }
    }
}