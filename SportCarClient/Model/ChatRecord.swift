//
//  ChatRecord.swift
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON

class ChatRecord: NSManagedObject {
    
    static let objects = ChatRecoardManager()
    
    /// 缓存的波形数据
    var cachedWaveData: [Float]?
    
    var imageSize: CGSize {
        set {
            self.imageWidth = Double(newValue.width)
            self.imageHeight = Double(newValue.height)
        }
        get {
            return CGSizeMake(CGFloat(self.imageWidth), CGFloat(self.imageHeight))
        }
    }
    
    var audioLengthInSec: Double = -1
    
    var readyForDisplay: Bool = false
    
    var contentImage: UIImage?
    
    var displayTimeMark: Bool = false
    
    /// 理论上来看，当产生了chatrecord时，对应的club和User都应当已经存在
    var targetUser: User?
    var targetClub: Club?
    
    func loadValueFromJSON(json: JSON) {
        self.createdAt = DateSTR(json["created_at"].string)
        self.chat_type = json["chat_type"].string
        self.textContent = json["text_content"].string
        let userJSON = json["sender"]
        self.sender = User.objects.create(userJSON).value
        self.image = json["image"].string
        self.targetID = json["target_id"].stringValue
        self.audio = json["audio"].string
        self.messageType = json["message_type"].string
        if chat_type == "private" && targetID != nil{
            targetUser = User.objects.getOrReload(targetID!)
        } else if chat_type == "group" && targetID != nil {
            targetClub = Club.objects.getOrLoad(targetID!)
        }
    }
    
    func getDescription() -> String {
        if messageType == "text" {
            return textContent!
        }else if messageType == "image" {
            return LS("[图片]")
        }else {
            return LS("[语音]")
        }
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
        textContent: String? = nil, image: UIImage?=nil, audio: NSURL? = nil, relatedID: String?=nil) -> ChatRecord{
        let hostUser = User.objects.hostUser
        let newChat = context.chatRecords.createEntity()
        newChat.createdAt = NSDate()
        newChat.chat_type = chatType
        newChat.textContent = textContent
        newChat.sender = hostUser
        newChat.targetID = targetID
        newChat.messageType = messageType
        newChat.sent = true
        newChat.contentImage = image
        newChat.audioLocal = audio?.absoluteString
        unSentRecord.append(newChat)
        return newChat
    }
    
    func confirmSent(newChat: ChatRecord, chatRecordID: String, image: String?=nil, audio: String?=nil) {
        newChat.sent = true
        newChat.recordID =  chatRecordID
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