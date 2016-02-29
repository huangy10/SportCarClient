//
//  ChatRecordDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Kingfisher

func getIdentifierForTargetIDAndChatRoomType(targetID: String, chatRoomType: String)-> String {
    return "\(targetID)_\(chatRoomType)"
}

func getIdentiferForChatRecord(chatRecord: ChatRecord) -> String{
    /* 
     注意，identifier是由对方id和聊天的类型组成的聊天窗口的唯一标识符
    */
    if chatRecord.chat_type == "private" {
        return "\(chatRecord.sender!.userID!)_\(chatRecord.chat_type!)"
    }else {
        return "\(chatRecord.club!.clubID!)_\(chatRecord.chat_type!)"
    }
}

func getIdentifierForRoomController(ctrler: ChatRoomController) -> String{
    let targetID: String
    if ctrler.targetClub != nil {
        targetID = ctrler.targetClub!.clubID!
    }else {
        targetID = ctrler.targetUser!.userID!
    }
    let roomType: String
    switch ctrler.roomType {
    case .Private:
        roomType = "private"
        break
    case .Club:
        roomType = "group"
        break
    }
    return "\(targetID)_\(roomType)"
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
    var totalUnreadNum: Int {
        get {
            var unread = 0
            let keys = chatRecords.keys
            for key in keys {
                let list = chatRecords[key]!
                let count = list.count
                for var i: Int = count-1; i >= 0; i-- {
                    if !list[i].read {
                        unread += 1
                    }else {
                        break
                    }
                }
            }
            return unread
        }
    }
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
            for data in json!.arrayValue {
                let semaphore = dispatch_semaphore_create(0)
                let newRecord = ChatRecord.objects.getOrCreateEmpty(data["chatID"].stringValue)
                newRecord.loadValueFromJSON(data)
                // 创建对应的消息
                print(data)
                print(newRecord)
                let identifier = getIdentiferForChatRecord(newRecord)
                //
                if let records = self.chatRecords[identifier] {
                    records.appendContentsOf([newRecord])
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
}

class ChatRecordList {
    private var _data: [ChatRecord] = []
    var _item: ChatRecordListItem!
    
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
}