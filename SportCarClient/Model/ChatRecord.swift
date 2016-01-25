//
//  ChatRecord.swift
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON

class ChatRecord: NSManagedObject {
    
    static let objects = ChatRecoardManager()
    
    func loadValueFromJSON(json: JSON) {
        self.createdAt = DateSTR(json["created_at"].string)
        self.chat_type = json["chat_type"].string
        self.textContent = json["text_content"].string
        let userJSON = json["user"]
        self.sender = User.objects.create(userJSON).value
        self.image = json["image"].string
        self.targetID = json["target_id"].string
        self.audio = json["audio"].string
        self.messageType = json["message_type"].string
    }
    
}

class ChatRecoardManager {
    let context = User.objects.context
    
    var unSentRecord: [ChatRecord] = []
    
    /**
     尝试从coredata中取出给定id的聊天记录，如果不存在则创建一个空的
     
     - parameter chatRecordID: 聊天记录的id
     
     - returns: 返回类型
     */
    func getOrCreateEmpty(chatRecordID: String) -> ChatRecord{
        return context.chatRecords.firstOrCreated( {$0.recordID == chatRecordID} )
    }
    
    func postNewChatRecord(chatType: String, messageType: String, targetID: String,
        textContent: String? = nil, image: String?=nil, audio: String? = nil, relatedID: String?=nil) -> ChatRecord{
        let hostUser = User.objects.hostUser
        let newChat = context.chatRecords.createEntity()
        newChat.createdAt = NSDate()
        newChat.chat_type = chatType
        newChat.textContent = textContent
        newChat.sender = hostUser
        newChat.image = image
        newChat.targetID = targetID
        newChat.audio = audio
        newChat.messageType = messageType
        newChat.sent = true
        unSentRecord.append(newChat)
        return newChat
    }
    
    func confirmSent(newChat: ChatRecord, chatRecordID: String, image: String?=nil, audio: String?=nil) {
        newChat.sent = true
        newChat.image = image
        newChat.audio = audio
        unSentRecord.remove(newChat)
        self.saveAll()
    }
    
    /**
     保持所有更改
     
     - returns: 是否保存成功
     */
    func saveAll() -> Bool{
        do {
            try context.save()
            return true
        } catch let error {
            print(error)
            return false
        }
    }
}