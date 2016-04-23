//
//  ChatRecordDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Kingfisher
import SwiftyJSON
import AlecrimCoreData

//func getIdentifierForTargetIDAndChatRoomType(targetID: String, chatRoomType: String)-> String {
//    return "\(targetID)_\(chatRoomType)"
//}

func getIdentifierForIdPair(id1: String, _ id2: String) -> String{
    let a = Int(id1)!
    let b = Int(id2)!
    if a < b {
        return "\(a)_\(b)"
    }else{
        return "\(b)_\(a)"
    }
}

func getIdentifierForChatRoom(room: ChatRoomController) -> String {
    switch room.roomType {
    case .Private:
        let senderID = ChatModelManger.sharedManager.hostUserID!
        let targetID = room.targetUser!.ssid
        if senderID < targetID {
            return "\(senderID)_\(targetID)"
        }else {
            return "\(targetID)_\(senderID)"
        }
    case .Club:
        return room.targetClub!.ssidString
    }
}

func getIdentiferForChatRecord(chatRecord: ChatRecord) -> String{
    /* 
     注意，identifier是由对方id和聊天的类型组成的聊天窗口的唯一标识符
    */
    if chatRecord.chatType == "private" {
        let senderID = chatRecord.senderUser!.ssid
        let targetID = chatRecord.targetUser!.ssid
        if senderID < targetID {
            return "\(senderID)_\(targetID)"
        }else {
            return "\(targetID)_\(senderID)"
        }
    }else {
        return chatRecord.targetClub!.ssidString
    }
}

enum ChatRecordListItem{
    case ClubItem(Club)
    case UserItem(User)
}

/// 统一管理所有的ChatRecords
class ChatRecordDataSource {
    
    static let sharedDataSource = ChatRecordDataSource()
    
    // 当前使用的聊天窗口
    var curRoom: ChatRoomController?
    var listCtrl: ChatListController?
    // 总的未读消息的数量
    var totalUnreadNum: Int = 0 {
        didSet {
            ss_sendUnreadNumberDidChangeNotification()
        }
    }
    // 所有的内存中的聊天条目
    var chatRecords = MyOrderedDict<String, ChatRecordList>()
    // 网络请求工具
    var requester: ChatRequester = ChatRequester.requester
    
    var started: Bool = false
    var pauser: dispatch_semaphore_t?
    
    /**
     create a chat record from a json record, might block the current thread so call it in a background thread
     */
    func parseChatRecordData(
        data: JSON,
        downloadAudio: Bool = true,
        autoBringToFront: Bool = true,
        reversed: Bool = false,
        unreadCheck: Bool = false
        ) -> ChatRecord {
            let messageType = data["message_type"].stringValue
            let newRecord = try! ChatModelManger.sharedManager.getOrCreate(data) as ChatRecord
            // get the locally unique identifier for the chat
            let identifier = getIdentiferForChatRecord(newRecord)
            // put the new record to the corresponding queue, if the queue does not exist, then create one
            if let records = chatRecords[identifier] {
                if reversed {
                    records.addAtFirst(newRecord)
                } else{
                    records.append(newRecord)
                }
                if unreadCheck {
                    if self.curRoom == nil || getIdentifierForChatRoom(self.curRoom!) != identifier {
                        self.totalUnreadNum += 1
                        records.unread += 1
                    }
                }
            } else {
                let newRecords = ChatRecordList()
                if newRecord.chatType == "private" {
                    var targetUser = try! ChatModelManger.sharedManager.getOrCreate(data["sender"]) as User
                    if targetUser.isHost {
                        targetUser = newRecord.targetUser!
                    }
                    newRecords._item = ChatRecordListItem.UserItem(targetUser)
                } else if newRecord.chatType == "group" {
                    let targetClub = try! ChatModelManger.sharedManager.getOrCreate(data["target_club"]) as Club
                    newRecords._item = ChatRecordListItem.ClubItem(targetClub)
                } else {
                    assertionFailure()
                }
                newRecords.append(newRecord)
                chatRecords[identifier] = newRecords
                if unreadCheck {
                    if self.curRoom == nil || getIdentifierForChatRoom(self.curRoom!) != identifier {
                        self.totalUnreadNum += 1
                        newRecords.unread += 1
                    }
                }
            }
            
            // Download file associated with the chat record
            if messageType == "audio" && downloadAudio {
                let semaphore = dispatch_semaphore_create(0)
                self.requester.download_audio_file_async(newRecord, onComplete: { (record, localURL) -> () in
                    // Analyse the audio file
                    record.audioLocal = localURL.absoluteString
                    let analyzer = AudioWaveDrawEngine(audioFileURL: localURL, preferredSampleNum: 30, onFinished: { (engine) -> () in
                        // Do nothing
                    }, async: false)
                    // Set up cache
                    record.cachedWaveData = analyzer.sampledata
                    record.audioLength = analyzer.lengthInSec
                    record.audioReady = true
                    dispatch_semaphore_signal(semaphore)
                    }, onError: { (record) -> () in
                        print("Error: fail to download the audio file")
                        dispatch_semaphore_signal(semaphore)
                })
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
            // bring the chat to the front of the list
            if autoBringToFront {
                chatRecords.bringKeyToFront(identifier)
            }
            return newRecord
    }
    
    /**
     从服务器获取聊天列表
     */
    func loadChatList() {
        self.requester.getChatList({ (json) -> () in
            // 处理聊天内容
            for data in json!["chats"].arrayValue {
                self.parseChatRecordData(data, autoBringToFront: true)
            }
            // 解析聊天设置
            for data in json!["club_settings"].arrayValue {
                let clubID = data["club"]["id"].int32Value
                if let club: Club = ChatModelManger.sharedManager.objectWithSSID(clubID) {
                    club.memberNum = data["club"]["members_num"].int32Value
                    club.updateClubSettings(data)
                    // 其他设置消息需呀单独手动配置
                    club.updateClubSettings(data["club"])
                }
            }
            self.chatRecords.resort({ (v1, v2) -> Bool in
                let chat1 = v1.last()
                let chat2 = v2.last()
                // TODO: always on top
                if chat1 == nil && chat2 == nil {
                    return false
                } else if chat2 == nil {
                    return true
                }
                switch chat1!.createdAt!.compare(chat2!.createdAt!) {
                case .OrderedDescending:
                    return true
                default:
                    return false
                }
            })
            // 个人聊天设置
            // TODO：个人聊天设置需要再考虑一下
//            for data in json!["private_settings"].arrayValue {
//                let userID = data["target_id"].stringValue
//                if let user = User.objects.getOrLoad(userID, ctx: ChatRecord.objects.context) {
//                    user.remarkName = data["remarkName"].string
//                }
//            }
            //
            do {
                try ChatModelManger.sharedManager.save()
            } catch {}
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.curRoom != nil{
                    self.curRoom?.needsUpdate()
                }else {
                    self.listCtrl?.needUpdate()
                }
                self.getUnreadInformation()
            })
            }) { (code) -> () in
        }
    }
    
    /**
     从服务器获取未读信息
     */
    func getUnreadInformation() {
        let requester = ChatRequester.requester
        requester.getUnreadInformation({ (json) -> () in
            for data in json!.arrayValue {
                let chatType = data["chat_type"].stringValue
                if chatType == "private" {
                    let user: User = try! ChatModelManger.sharedManager.getOrCreate(data["user"])
                    let identifier = getIdentifierForIdPair(user.ssidString, ChatModelManger.sharedManager.hostUserIDString!)
                    if let records = self.chatRecords[identifier] {
                        records.unread = data["unread"].intValue
                        self.totalUnreadNum += records.unread
                    }else{
                        let newRecords = ChatRecordList()
                        newRecords._item = ChatRecordListItem.UserItem(user)
                        newRecords.unread = data["unread"].intValue
                        self.totalUnreadNum += newRecords.unread
                    }
                }else {
                    let club: Club = try! ChatModelManger.sharedManager.getOrCreate(data["club"])
                    let identifier = club.ssidString
                    if let records = self.chatRecords[identifier] {
                        records.unread = data["unread"].intValue
                        self.totalUnreadNum += records.unread
                    }else{
                        let newRecords = ChatRecordList()
                        newRecords._item = ChatRecordListItem.ClubItem(club)
                        newRecords.unread = data["unread"].intValue
                        self.totalUnreadNum += newRecords.unread
                    }
                }
            }
            self.listCtrl?.needUpdate()
            }) { (code) -> () in
        }
    }
    
    func start() {
        /* 初始创建时启动监听
        */
        if pauser != nil {
            dispatch_semaphore_signal(pauser!)
            pauser = nil
        }
        if started {
            return
        }
        started = true
        self.loadChatList()
        self.requester.startListenning({ (let json) -> () in
            for data in json.arrayValue {
                self.parseChatRecordData(data, unreadCheck: true)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.curRoom != nil {
                    self.curRoom?.needsUpdate()
                }else {
                    self.listCtrl?.needUpdate()
                }
            })
            }) { (code) -> () in
        }
    }
    
    func pause() {
        requester.chatRequest?.cancel()
        started = false
        pauser = dispatch_semaphore_create(0)
        dispatch_async(ChatRequester.requester.privateQueue) { () -> Void in
            // TODO : 将这个功能整合进ChatRequester，在阻塞这个queue之前要注意取消上一次监听请求
            dispatch_semaphore_wait(self.pauser!, DISPATCH_TIME_FOREVER)
        }
    }
    
    /**
     根据给定的index来获取chatlist的item，返回的类型可能是club或者是user，使用了一个枚举类型来获取
     
     - parameter index: 下标
     
     - returns: 用枚举类型打包
     */
    func getItemForIndex(index: Int) -> ChatRecordListItem? {
        let key = self.chatRecords.keys[index]
        return self.chatRecords[key]?._item
    }
    
    /**
     载入历史聊天数据
     */
    func parseHistoryFromServer(json: JSON) {
        for data in json.arrayValue {
            self.parseChatRecordData(data, autoBringToFront: false, reversed: true)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.curRoom != nil{
                self.curRoom?.needsUpdate()
            }else {
                self.listCtrl?.needUpdate()
            }
        })
    }
    
    func clearChatContentForIdentifier(identifier: String) {
        if let records = chatRecords[identifier] {
            records.clear()
        }
    }
    
    func deleteClub(club: Club) {
        clearChatContentForIdentifier(club.ssidString)
        chatRecords[club.ssidString] = nil
        self.listCtrl?.needUpdate()
    }
    
    func flushAll() {
        do {
            try ChatModelManger.sharedManager.save()
        } catch {
            print("ChatModelManager: Fail to save")
        }
        self.chatRecords.removeAll()
    }
}

class ChatRecordList {
    private var _data: [ChatRecord] = []
    var _item: ChatRecordListItem!
    /// 未读消息数量
    var unread: Int = 0
    
    subscript (index: Int) -> ChatRecord! {
        get {
            return _data[index]
        }
        set {
            _data[index] = newValue
        }
    }
    
    var count: Int {
        return _data.count
    }
    
    func append(chat: ChatRecord) {
        _data.append(chat)
    }
    
    func appendContentsOf(data: [ChatRecord]) {
        _data.appendContentsOf(data)
    }
    
    func first() -> ChatRecord?{
        return _data.first
    }
    
    func last() -> ChatRecord? {
        return _data.last
    }
    
    func addAtFirst(chat: ChatRecord) {
        _data.insert(chat, atIndex: 0)
    }
    
    func clear() {
        _data = _data.filter { (record) -> Bool in
            return record.messageType == "placeholder"
        }
    }
}