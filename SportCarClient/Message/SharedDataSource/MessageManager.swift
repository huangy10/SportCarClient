//
//  MessageManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Kingfisher
import AlecrimCoreData
import Alamofire

/*
 In this new MessageManager, we reconstruct the model layer of the entire message module. Below are the major changes:
 1. Combine the listening queue of the notifications and chats
 2. Deprecate the polling of the notifications
 3. Simplify the interface of the manager
 4. Redefine the identifier system of the chats (private & group)
 */

class MessageManager {
    
    static let defaultManager = MessageManager()
    
    /// Current ongoing request to the server
    private weak var request: Request?
    
    /// Current status of the manager
    private var state: State = .IDLE
    
    /// The working queue of the manager
    private var queue: dispatch_queue_t! {
        return ChatModelManger.sharedManager.workQueue
    }
    
    private var manager: Manager {
        return ChatRequester2.sharedInstance.manager
    }
    
    private var url: String {
        return "\(kProtocalName)://\(kHostName):\(kChatPortName)/chat/update"
    }
    
    var hostUser: User! {
        return MainManager.sharedManager.hostUser
    }
    
    var anonymous: Bool {
        return MainManager.sharedManager.hostUser == nil
    }
    var unreadChatNum: Int = 0 {
        didSet {
            if oldValue != unreadChatNum {
                ss_sendUnreadNumberDidChangeNotification()
            }
        }
    }
    var unreadNotifNum: Int = 0 {
        didSet {
            if oldValue != unreadNotifNum {
                ss_sendUnreadNumberDidChangeNotification()
            }
        }
    }
    var unreadNum: Int {
        return unreadChatNum + unreadNotifNum
    }
    
    func connect() {
        if anonymous {
            self.state = .IDLE
            return
        }
        // start listening on private queue
        state = .ONGOING
        dispatch_barrier_async(queue) { self.sync() }
        dispatch_async(queue) { self.listen() }
    }
    
    /**
     Synchronous the local storage of messages
     */
    private func sync() {
        // Sync the roster
        RosterManager.defaultManager.sync()
    }
    
    /**
     This function monitor the status of the server and request the realtime chat content
     */
    private func listen() {
        guard !NSThread.isMainThread() else {
            state = .ERROR
            assertionFailure("Cannot listen the the chat server on main thread")
            return
        }
        guard state == .ONGOING else {
            return
        }
        if let req = request {
            // incase that there is already an ongoing request
            req.cancel()
        }
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        // big enough so that it never timeout
        mutableRequest.timeoutInterval = 3600
        // send request to the server
        request = ChatRequester2.sharedInstance.listen(
            queue, unread: self.unreadNum, curFocusedChat: _curRoom?.rosterItem.ssid ?? 0, onSuccess: { (json) in
                // 128 是和服务器约定的信息缓存队列的长度
                if json == nil {
                    return
                }
                if json!.arrayValue.count >= 128 {
                    // 此处的含义为，当一次性接收到的消息的数量超过了128，则认为我们已经漏掉了
                    // 部分消息（128为服务器消息缓存队列的长度），
                    self.reset()
                }
                do {
                    try self.parse(json!.arrayValue)
//                    for data in json!.arrayValue {
//                        try self.parse(data)
//                    }
                } catch let err {
                    print(err)
                    self.state = .ERROR
                }
                try! ChatModelManger.sharedManager.save()
                dispatch_async(dispatch_get_main_queue(), { 
                    RosterManager.defaultManager.rosterList?.reloadData()
                })
                // re-send the request
                self.request = nil
                dispatch_async(self.queue) { self.listen() }
            }, onError: { (code) in
                if let code = code {
                    self.errorHanlde(code)
                }
//                self.state = .ERROR
//                try! ChatModelManger.sharedManager.save()
                // re-send the request
                self.request = nil
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 3))
                dispatch_after(delay, self.queue, { 
                    self.listen()
                })
        })
    }
    
    func disconnect() {
        if let request = request {
            // if there is an ongoing request, cancel it
            request.cancel()
        }
        state = .IDLE
    }
    
    func errorHanlde(message: String) {
        
    }
    
    func parse(data: [SwiftyJSON.JSON]) throws {
        var chatDirty = false
        var notifDirty = false
        for json in data {
            if json["chatID"].exists() {
                let result = try ChatParser().parse(json)
                let chat = result.0
//                if let rosterItem = result.1 {
//                    rosterItem.recentChatDes = chat.summary
//                    RosterManager.defaultManager.addNewRosterItem(rosterItem)
//                }
                if let curRoom = _curRoom {
                    if curRoom.rosterItem.takeChatRecord(chat) {
                        curRoom.chats.append(chat)
                        chatDirty = true
                    } else {
                        unreadChatNum += 1
                    }
                } else {
                    unreadChatNum += 1
                }
            } else if json["notification_id"].exists() {
                // 注意从服务器返回的消息是按照createdAt降序排列的
                let notif = try NotificationParser().parse(json)
                if let list = _curNotifList {
                    list.data.insert(notif, atIndex: 0)
                }
                
                self.unreadNotifNum += 1
                notifDirty = true
            } else if json["ssid"].exists() {
                // rosterItem change
            } else {
                throw SSModelError.NotSupported
            }
        }
        if chatDirty {
            dispatch_async(dispatch_get_main_queue(), { 
                if let room = self._curRoom {
                    if !room.viewingHistory {
                        room.talkBoard?.reloadData()
                        room.talkBoard?.scrollToRowAtIndexPath(NSIndexPath(forRow: room.chats.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
                    } else {
                        room.talkBoard?.reloadData()
                    }
                }
            })
        }
        if notifDirty {
            dispatch_async(dispatch_get_main_queue(), { 
                if let list = self._curNotifList {
                    list.tableView.reloadData()
                }
            })
        }
    }

    /**
     调用这个函数时，意味着client判定和服务器的同步状态出现问题
     */
    func reset() {
        assert(!NSThread.isMainThread())
        assert(!anonymous)
        
        state = .SYNCING
        // FIRST: 清除本地缓存的信息
        let context = ChatModelManger.sharedManager.getOperationContext()
        do {
            // delete the cached chat records
            try context.chatRecords.filter({
                $0.hostSSID == MainManager.sharedManager.hostUserID!
            }).delete()
            // delete the cached notifications
            try context.notifications.filter({
                $0.hostSSID == MainManager.sharedManager.hostUserID!
            }).delete()
        } catch {}
        NSNotificationCenter.defaultCenter().postNotificationName(kMessageChatResetNotification, object: self)
        state = .ONGOING
    }
    
    enum State {
        case IDLE, ONGOING, ERROR, OFFLINE, SYNCING
    }
    
    // MARK: chat room handle
    
    weak var _curRoom: ChatRoomController?
    
    func enterRoom(room: ChatRoomController) {
        
        if room.chats.count > 0 {
            return
        }
        
        func load(onFinish: (Void -> Void)? = nil) {
            dispatch_async(queue) {
                let chats = ChatModelManger.sharedManager.loadCachedChats(room.rosterItem.ssid, skips: 0, limit: 20)
                room.chats.appendContentsOf(chats)
                if chats.count > 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        room.talkBoard?.reloadData()
                        room.talkBoard?.scrollToRowAtIndexPath(NSIndexPath(forRow: room.chats.count - 1, inSection: 0)
                            , atScrollPosition: .Top, animated: false)
                    })
                }
                self.unreadChatNum = max(0, self.unreadChatNum - Int(room.rosterItem.unreadNum))
                // clear the unread number
                if room.rosterItem.unreadNum > 0 {
                    room.rosterItem.unreadNum = 0
                }
                self._curRoom = room
                // update listening status
                self.listen()
                
                if let handler = onFinish {
                    handler()
                }
            }
        }
        
        if !room.chatCreated {
            // 其他的走这里
            var targetID: Int32 = 0
            var chatType: String = ""
            if let user = room.targetUser {
                if let rosterItem = user.rosterItem {
                    room.rosterItem = rosterItem
                    load()
                    return
                } else {
                    targetID = user.ssid
                    chatType = "user"
                }
            } else if let club = room.targetClub {
                if let rosterItem = club.rosterItem {
                    room.rosterItem = rosterItem
                    load()
                    return
                } else {
                    targetID = club.ssid
                    chatType = "club"
                }
            }
            // 进入这里说明没有在已有的rosterItems中找到已有的rosterItem，故这里向服务器提交请求
            ChatRequester2.sharedInstance.startChat("\(targetID)", chatType: chatType, onSuccess: { (json) in
                let rosterItem = RosterManager.defaultManager.getOrCreateNewRoster(json!, autoBringToFront: true)
                room.rosterItem = rosterItem
                //
                load()
                }, onError: { (code) in
                    // do nothing when error occurs
            })
        } else {
            load({
                // 如果没有从本地数据库里面查找到数据，那么尝试获取历史
                if room.chats.count == 0 {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        room.refresh.beginRefreshing()
//                        room.loadChatHistoryMannually(false)
//                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { 
                        room.talkBoard?.reloadData()
                    })
                }
            })
        }
    }
    
    func leaveRoom() {
        _curRoom = nil
        // update listening status
        dispatch_async(queue) { 
            self.listen()
        }
    }
    
    func newMessageSent(chat: ChatRecord) {
        
    }
    /**
     返回的chats按照createdAt降序排列
     */
    func loadHistory(room: ChatRoomController, onFinished: (chats: [ChatRecord]?)->()) {
        if state != .ONGOING {
            onFinished(chats: nil)
        }
        dispatch_async(queue) {    
            var chats = ChatModelManger.sharedManager.loadCachedChats(room.rosterItem.ssid, skips: room.chats.count, limit: 20)
            if chats.count < 20 {
                ChatRequester2.sharedInstance.getChatHistories(room.rosterItem.ssid, skips: room.chats.count + chats.count, limit: 20 - chats.count, onSucces: { (json) in
                    let parser = ChatParser()
                    for data in json!.arrayValue {
                        let result = try! parser.parse(data).0
                        result.rosterID = room.rosterItem.ssid
                        chats.insert(result, atIndex: 0)
                    }
                    dispatch_async(dispatch_get_main_queue(), { 
                        onFinished(chats: chats)
                    })
                    }, onError: { (code) in
                        dispatch_async(dispatch_get_main_queue()) {
                            onFinished(chats: nil)
                        }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    onFinished(chats: chats)
                })
            }
        }
    }
    
    func clearChatHistory(rosterItem: RosterItem) {
        func _clear(rosterItem: RosterItem) {
            let context = ChatModelManger.sharedManager.getOperationContext()
            do {
                try context.chatRecords
                    .filter({$0.hostSSID == self.hostUser.ssid})
                    .filter({$0.rosterID == rosterItem.ssid})
                    .delete()
                NSNotificationCenter.defaultCenter().postNotificationName(kMessageChatHistoryCleared, object: nil, userInfo: [kRosterItemKey: rosterItem])
            } catch {}
        }
        
        if NSThread.isMainThread() {
            dispatch_async(self.queue, { 
                _clear(rosterItem)
            })
        } else {
            _clear(rosterItem)
        }
    }
    
    func clearChatHistory(club: Club) {
        let context = ChatModelManger.sharedManager.getOperationContext()
        if let roster = context.rosterItems.filter({ $0.hostSSID == self.hostUser.ssid })
            .first({ $0.relatedID == club.ssid && $0.entityType == "club" }) {
            self.clearChatHistory(roster)
        }
    }
    
    func deleteAndQuit(club: Club) {
        RosterManager.defaultManager.deleteAndQuitClub(club)
    }
    
    // MARK: - notificaiton list handle
    
    weak var _curNotifList: NotificationController?
    
    func enterNotificationList(list: NotificationController) {
        _curNotifList = list
        self.unreadNotifNum = 0
        if list.data.count > 0 {
            return
        }
        dispatch_async(queue) { 
            let notifs = ChatModelManger.sharedManager.loadCachedNotifications(0, limit: 20)
            list.data.appendContentsOf(notifs)
            if notifs.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { 
                    list.tableView.reloadData()
                })
            } else {
                // 如果进入通知列表时通知列表是空的，尝试向服务器请求
                NotificationRequester.sharedInstance.getNotifications(0, onSuccess: { (json) in
                    let parser = NotificationParser()
                    for data in json!.arrayValue {
                        do {
                            let notif = try parser.parse(data)
                            list.data.append(notif)
                        } catch { continue }
                    }
                    dispatch_async(dispatch_get_main_queue(), { 
                        list.tableView.reloadData()
                    })
                    }, onError: { (code) in
                        
                })
            }
        }
    }
    
    func leaveNotificationList() {
        
    }
    
    func loadHistory(list: NotificationController, onFinish: (notifs: [Notification]?) -> ()) {
        if state != .ONGOING {
            onFinish(notifs: nil)
        }
        dispatch_async(queue) { 
            var notifs = ChatModelManger.sharedManager.loadCachedNotifications(list.data.count, limit: 20)
            if notifs.count < 20 {
                // contact server
                NotificationRequester.sharedInstance.getNotifications(list.data.count + notifs.count, limit: 20 - notifs.count, onSuccess: { (json) in
                    let parser = NotificationParser()
                    for data in json!.arrayValue {
                        do {
                            let notif = try parser.parse(data)
                            notifs.append(notif)
                        } catch { continue }
                    }
                    dispatch_async(dispatch_get_main_queue(), { 
                        onFinish(notifs: notifs)
                    })
                    }, onError: { (code) in
                        dispatch_async(dispatch_get_main_queue(), { 
                            onFinish(notifs: nil)
                        })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { 
                    onFinish(notifs: notifs)
                })
            }
        }
    }
}
