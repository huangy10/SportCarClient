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
        let senderID = Int(User.objects.hostUser(ChatRecord.objects.context)!.userID!)!
        let targetID = Int(room.targetUser!.userID!)!
        if senderID < targetID {
            return "\(senderID)_\(targetID)"
        }else {
            return "\(targetID)_\(senderID)"
        }
    case .Club:
        return room.targetClub!.clubID!
    }
}

func getIdentiferForChatRecord(chatRecord: ChatRecord) -> String{
    /* 
     注意，identifier是由对方id和聊天的类型组成的聊天窗口的唯一标识符
    */
    if chatRecord.chat_type == "private" {
        let senderID = Int(chatRecord.sender!.userID!)!
        let targetID = Int(chatRecord.targetUser!.userID!)!
        if senderID < targetID {
            return "\(senderID)_\(targetID)"
        }else {
            return "\(targetID)_\(senderID)"
        }
    }else {
        return chatRecord.targetClub!.clubID!
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
    var totalUnreadNum: Int = 0
    // 所有的内存中的聊天条目
    var chatRecords = MyOrderedDict<String, ChatRecordList>()
    // 网络请求工具
    var requester: ChatRequester = ChatRequester.requester
    
    var started: Bool = false
    
    /**
     从服务器获取聊天列表
     */
    func loadChatList() {
        self.requester.getChatList({ (json) -> () in
            // 处理聊天内容
            for data in json!["chats"].arrayValue {
                let semaphore = dispatch_semaphore_create(0)
                let newRecord = ChatRecord.objects.getOrCreateEmpty(data["chatID"].stringValue)
                newRecord.loadValueFromJSON(data)
                // 创建对应的消息
                let identifier = getIdentiferForChatRecord(newRecord)
                //
                if let records = self.chatRecords[identifier] {
                    records.appendContentsOf([newRecord])
                }else{
                    let newRecords = ChatRecordList()
                    if newRecord.chat_type == "private" {
                        var target_user = User.objects.create(data["sender"], ctx: ChatRecord.objects.context).value
                        let host = User.objects.hostUser(ChatRecord.objects.context)
                        if target_user?.userID == host?.userID {
                            target_user = newRecord.targetUser
                        }
                        newRecords._item = ChatRecordListItem.UserItem(target_user!)
                    }else {
                        let target_club = Club.objects.getOrCreate(data["target_club"])
                        newRecords._item = ChatRecordListItem.ClubItem(target_club!)
                    }
                    newRecords.appendContentsOf([newRecord])
                    self.chatRecords[identifier] = newRecords
                }
                //                self.chatRecords[identifier]?.appendContentsOf([newRecord])
                if newRecord.messageType == "audio"{
                    // 如果是音频数据的话直接开始下载
                    self.requester.download_audio_file_async( newRecord, onComplete: { (record, localURL) -> () in
                        // 下载完成后开始分析波形
                        record.audioLocal = localURL.absoluteString
                        let anaylzer = AudioWaveDrawEngine(audioFileURL: localURL, preferredSampleNum: 30, onFinished: { (engine) -> () in
                            }, async: false)
                        record.cachedWaveData = anaylzer.sampledata
                        record.audioLengthInSec = anaylzer.lengthInSec
                        record.readyForDisplay = true
                        // 重新载入数据
                        // self.talkBoard?.reloadData()
                        dispatch_semaphore_signal(semaphore)
                        }, onError: { (record) -> () in
                            dispatch_semaphore_signal(semaphore)
                    })
                }else if newRecord.messageType == "image" {
                    let downloader = KingfisherManager.sharedManager.downloader
                    let targetURL = SFURL(newRecord.image!)!
                    downloader.downloadImageWithURL(targetURL, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                        newRecord.contentImage = image
                        dispatch_semaphore_signal(semaphore)
                    })
                }else{
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                self.chatRecords.bringKeyToFront(identifier)
            }
            // 解析聊天设置
            for data in json!["club_settings"].arrayValue {
                let clubID = data["club"]["id"].stringValue
                if let club = Club.objects.getOrLoad(clubID) {
                    club.clubJoining?.updateFromJson(data)
                    // 其他设置消息需呀单独手动配置
                    club.onlyHostInvites = data["club"]["only_host_can_invite"].boolValue
                    club.show_members = data["club"]["show_members_to_public"].boolValue
                }
            }
            // 个人聊天设置
            for data in json!["private_settings"].arrayValue {
                let userID = data["target_id"].stringValue
                if let user = User.objects.getOrLoad(userID) {
                    user.remarkName = data["remarkName"].string
                }
            }
            //
            ChatRecord.objects.saveAll()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.curRoom != nil{
                    self.curRoom?.needsUpdate()
                }else {
                    self.listCtrl?.needUpdate()
                }
                self.getUnreadInformation()
            })
            }) { (code) -> () in
                print(code)
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
                    let user = User.objects.create(data["user"]).value
                    let identifier = getIdentifierForIdPair(user!.userID!, User.objects.hostUser(ChatRecord.objects.context)!.userID!)
                    if let records = self.chatRecords[identifier] {
                        records.unread = data["unread"].intValue
                        self.totalUnreadNum += records.unread
                    }else{
                        let newRecords = ChatRecordList()
                        newRecords._item = ChatRecordListItem.UserItem(user!)
                        newRecords.unread = data["unread"].intValue
                        self.totalUnreadNum += newRecords.unread
                    }
                }else {
                    let club = Club.objects.getOrCreate(data["club"])!
                    let identifier = club.clubID!
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
                print(code)
        }
    }
    
    func start() {
        /* 初始创建时启动监听
        */
        if started {
            return
        }
        started = true
        self.loadChatList()
        self.requester.startListenning({ (let json) -> () in
            for data in json.arrayValue {
                let semaphore = dispatch_semaphore_create(0)
                let newRecord = ChatRecord.objects.getOrCreateEmpty(data["chatID"].stringValue)
                newRecord.loadValueFromJSON(data)
                // 创建对应的消息
                let identifier = getIdentiferForChatRecord(newRecord)
                //
                if let records = self.chatRecords[identifier] {
                    records.appendContentsOf([newRecord])
                    if newRecord.sender?.userID != User.objects.hostUserID {
                        if self.curRoom == nil || getIdentifierForChatRoom(self.curRoom!) != identifier {
                            records.unread += 1
                            self.totalUnreadNum += 1
                        }
                    }
                }else{
                    let newRecords = ChatRecordList()
                    if newRecord.chat_type == "private" {
                        let target_user = User.objects.create(data["sender"]).value
                        newRecords._item = ChatRecordListItem.UserItem(target_user!)
                    }else {
                        let target_club = Club.objects.getOrCreate(data["target_club"])
                        newRecords._item = ChatRecordListItem.ClubItem(target_club!)
                    }
                    newRecords.appendContentsOf([newRecord])
                    self.chatRecords[identifier] = newRecords
                    newRecords.unread = 1
                    self.totalUnreadNum += 1
                }
//                self.chatRecords[identifier]?.appendContentsOf([newRecord])
                if newRecord.messageType == "audio"{
                    // 如果是音频数据的话直接开始下载
                    self.requester.download_audio_file_async( newRecord, onComplete: { (record, localURL) -> () in
                        // 下载完成后开始分析波形
                        record.audioLocal = localURL.absoluteString
                        
                        let anaylzer = AudioWaveDrawEngine(audioFileURL: localURL, preferredSampleNum: 30, onFinished: { (engine) -> () in
                        }, async: false)
                        
                        record.cachedWaveData = anaylzer.sampledata
                        record.audioLengthInSec = anaylzer.lengthInSec
                        record.readyForDisplay = true
                        // 重新载入数据
                        // self.talkBoard?.reloadData()
                        dispatch_semaphore_signal(semaphore)
                        }, onError: { (record) -> () in
                             dispatch_semaphore_signal(semaphore)
                    })
                }else if newRecord.messageType == "image" {
                    let downloader = KingfisherManager.sharedManager.downloader
                    let targetURL = SFURL(newRecord.image!)!
                    downloader.downloadImageWithURL(targetURL, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                        newRecord.contentImage = image
                        dispatch_semaphore_signal(semaphore)
                    })
                }else{
                    dispatch_semaphore_signal(semaphore)
                }
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                self.chatRecords.bringKeyToFront(identifier)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.curRoom != nil {
                    self.curRoom?.needsUpdate()
                }else {
                    self.listCtrl?.needUpdate()
                }
            })
            }) { (code) -> () in
                print(code)
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
            let semaphore = dispatch_semaphore_create(0)
            let newRecord = ChatRecord.objects.getOrCreateEmpty(data["chatID"].stringValue)
            newRecord.loadValueFromJSON(data)
            //
            let identifier = getIdentiferForChatRecord(newRecord)
            //
            if let records = self.chatRecords[identifier] {
                records.addAtFirst(newRecord)
            }else{
                let newRecords = ChatRecordList()
                if newRecord.chat_type == "private" {
                    var target_user = User.objects.create(data["sender"]).value
                    if target_user?.userID == User.objects.hostUserID {
                        target_user = newRecord.targetUser
                    }
                    newRecords._item = ChatRecordListItem.UserItem(target_user!)
                }else {
                    let target_club = Club.objects.getOrCreate(data["target_club"])
                    newRecords._item = ChatRecordListItem.ClubItem(target_club!)
                }
                newRecords.addAtFirst(newRecord)
                self.chatRecords[identifier] = newRecords
            }
            //                self.chatRecords[identifier]?.appendContentsOf([newRecord])
            if newRecord.messageType == "audio"{
                // 如果是音频数据的话直接开始下载
                self.requester.download_audio_file_async( newRecord, onComplete: { (record, localURL) -> () in
                    // 下载完成后开始分析波形
                    record.audioLocal = localURL.absoluteString
                    
                    let anaylzer = AudioWaveDrawEngine(audioFileURL: localURL, preferredSampleNum: 30, onFinished: { (engine) -> () in
                        }, async: false)
                    
                    record.cachedWaveData = anaylzer.sampledata
                    record.audioLengthInSec = anaylzer.lengthInSec
                    record.readyForDisplay = true
                    // 重新载入数据
                    // self.talkBoard?.reloadData()
                    dispatch_semaphore_signal(semaphore)
                    }, onError: { (record) -> () in
                        dispatch_semaphore_signal(semaphore)
                })
            }else if newRecord.messageType == "image" {
                let downloader = KingfisherManager.sharedManager.downloader
                let targetURL = SFURL(newRecord.image!)!
                downloader.downloadImageWithURL(targetURL, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) -> () in
                    newRecord.contentImage = image
                    dispatch_semaphore_signal(semaphore)
                })
            }else{
                dispatch_semaphore_signal(semaphore)
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            self.chatRecords.bringKeyToFront(identifier)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.curRoom != nil{
                self.curRoom?.needsUpdate()
            }else {
                self.listCtrl?.needUpdate()
            }
        })
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
}