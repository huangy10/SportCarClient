//
//  RosterManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class RosterManager {
    static let defaultManager = RosterManager()
    /// The data of the roster
    var data: MyOrderedDict<String, RosterModelInterface>!
    /// The rosterList
    weak var rosterList: UITableView?
    
    var queue: dispatch_queue_t {
        return ChatModelManger.sharedManager.workQueue
    }
    /**
     Invoked when new message appears, including messages sent by the current user
     */
    func onNewChatRecordMerged(notification: NSNotification) {
        
    }
    
    /**
     Request roster list from server, work on the Message queue
     */
    func sync() {
        dispatch_async(queue) { 
            self._sync()
        }
    }
    
    /**
     actual working queue
     */
    private func _sync() {
        ChatRequester.requester.getChatList({ (json) in
            // TODO: Remake this interface
            }) { (code) in
                
        }
    }
}
