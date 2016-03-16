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
    var targetClub: Club? {
        didSet {
            club = targetClub
        }
    }
    
    var targetJoin: ClubJoining? {
        didSet {
            
        }
    }
    
    func loadValueFromJSON(json: JSON, ctx: DataContext? = nil) {
        self.createdAt = DateSTR(json["created_at"].string)
        self.chat_type = json["chat_type"].string
        self.textContent = json["text_content"].string
        let userJSON = json["sender"]
        sender = User.objects.getOrCreate(userJSON, ctx: ctx)
        if sender?.userID == User.objects.hostUser(ctx)?.userID {
            self.read = true
        }
        self.image = json["image"].string
        self.imageWidth = json["image_width"].doubleValue
        self.imageHeight = json["image_height"].doubleValue
        self.targetID = json["target_id"].stringValue
        self.audio = json["audio"].string
        self.messageType = json["message_type"].string
        self.read = json["read"].bool ?? false
        if chat_type == "private" && targetID != nil{
            targetUser = User.objects.getOrCreate(json["target_user"], ctx: ctx)
        } else if chat_type == "group" && targetID != nil {
            targetClub = Club.objects.getOrLoad(targetID!, ctx: ChatRecord.objects.context)
            if targetClub == nil {
                targetClub = Club.objects.getOrCreate(json["target_club"], ctx: ChatRecord.objects.context)
            }
            club = targetClub
        }
    }
    
    func getDescription() -> String {
        if messageType == "text" {
            return textContent!
        } else if messageType == "image" {
            return LS("[图片]")
        } else if messageType == "audio" {
            return LS("[语音]")
        } else {
            return ""
        }
    }
}

class ChatRecoardManager {
    let context = DataContext(parentDataContext: User.objects.defaultContext)
    
    var unSentRecord: [ChatRecord] = []
    
    /**
     尝试从coredata中取出给定id的聊天记录，如果不存在则创建一个空的
     
     - parameter chatRecordID: 聊天记录的id
     
     - returns: 返回类型
     */
    func getOrCreateEmpty(chatRecordID: String) -> ChatRecord{
        return context.chatRecords.firstOrCreated( {$0.recordID == chatRecordID} )
    }
    
    /**
     创建一个聊天条目以供发送到服务器。这里只设置了聊天的内容，其他相关配置在外部完成
     
     - parameter messageType: 消息类型text/audio/image
     - parameter targetID:    目标id
     - parameter textContent: 文本内容
     - parameter image:       发送的图片
     - parameter audio:       发送的音频
     - parameter relatedID:   关联id
     
     - returns: 返回一个创建成果的聊天条目
     */
    func postNewChatRecord(messageType: String, textContent: String? = nil, image: UIImage?=nil, audio: NSURL? = nil, relatedID: String?=nil) -> ChatRecord{
        let hostUser = User.objects.hostUser(context)
        let newChat = context.chatRecords.createEntity()
        newChat.createdAt = NSDate()
        newChat.textContent = textContent
        newChat.sender = hostUser
        newChat.messageType = messageType
        newChat.sent = true
        newChat.contentImage = image
        newChat.imageWidth = Double(image?.size.width ?? 0)
        newChat.imageHeight = Double(image?.size.height ?? 0)
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

// MARK: - Local utility
extension ChatRecoardManager {
    
    /**
     这个地方的逻辑是这样的：当从服务器获取到chat list时，将list给出的more recent chat record的id（注意此时不要将其存入数据库）传入此处检查是否这个最新的chatRecord已经存在了，如果存在了就以此为基点向前索取
     如果网络获取chatlist失败，则传入一个空的id
     */
    func loadLocalRecord(latest: String?, limit: Int) -> [ChatRecord]{
        if latest != nil {
            let latestRecord = context.chatRecords.first({ $0.recordID == latest })
            if latestRecord == nil {
                // 没有找到本地副本，返回空
                return []
            }
            let records: [ChatRecord] = context.chatRecords.filter({$0.createdAt >= latestRecord!.createdAt!})
                .orderByDescending({$0.createdAt})
                .take(limit).toArray()
            return records
        }
        return []
    }
}