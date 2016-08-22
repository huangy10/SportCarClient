//
//  ChatRecord.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

class ChatRecord: BaseModel {
    
    override class var idField: String {
        return "chatID"
    }
    
    var chatID: String {
        if chatType! == "private" {
            if senderUser!.isHost {
                return "p" + targetUser!.ssidString
            } else {
                return "p" + senderUser!.ssidString
            }
        } else {
            return "g" + targetClub!.ssidString
        }
    }
    
    private var _cachedWaveData: [Float]?
    var cachedWaveData: [Float]? {
        get {
            if _cachedWaveData == nil {
                if let cache = self.audioCaches {
                    let data = JSON(data: cache.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!).arrayValue
                    _cachedWaveData = data.map { $0.floatValue }
                } else {
                    _cachedWaveData = nil
                }
            }
            return _cachedWaveData
        }
        set {
            _cachedWaveData = newValue
        }
    }
    var displayTimeMark: Bool = false
    
    private var _senderUser: Chater? {
        didSet {
            _senderUser?.chat = self
        }
    }
    
    var senderUser : Chater? {
        if mine {
            let chater = manager.hostUser?.toChatter()
            chater?.chat = self
            return chater
        }
        assert(sender != nil, "No sender for chat")
        if _senderUser == nil {
            let json = JSON(data: sender!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            _senderUser = try! Chater().loadDataFromJSON(json)
            _senderUser?.chat = self
        }
        return _senderUser
    }
    
    var imageSize: CGSize! {
        return CGSizeMake(CGFloat(imageWidth), CGFloat(imageHeight))
    }
    
    var imageURL: NSURL! {
        return SFURL(image!)!
    }
    
    var contentImage: UIImage?
    
    private var _targetUser: User?
    var targetUser: User? {
        get {
            assert(relatedUser != nil, "")
            if _targetUser == nil {
                let json = JSON(data: relatedUser!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
                _targetUser = try! manager.getOrCreate(json) as User
            }
            return _targetUser
        }
        set {
            _targetUser = newValue
            relatedUser = try! _targetUser?.toJSONString(0)
        }
    }
    
    private var _targetClub: Club?
    var targetClub: Club? {
        get {
            assert(relatedClub != nil, "")
            if _targetClub == nil {
                let json = JSON(data: relatedClub!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
                _targetClub = try! manager.getOrCreate(json) as Club
            }
            return _targetClub
        }
        set {
            _targetClub = newValue
            relatedClub = try! _targetClub?.toJSONString(0)
        }
    }
    
    var targetIDString: String {
        return "\(targetID)"
    }
    var summary: String {
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

    override func loadDataFromJSON(data: JSON, detailLevel: Int, forceMainThread: Bool = false) throws -> ChatRecord {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        rosterID = data["roster"]["ssid"].int32Value
        createdAt = DateSTR(data["created_at"].stringValue)
        chatType = data["chat_type"].stringValue
        textContent = data["text"].stringValue
        let userJSON = data["sender"]
        sender = userJSON.rawString()
        _senderUser = try Chater().loadDataFromJSON(userJSON)
        _senderUser?.chat = self
        mine = _senderUser?.ssid == manager.hostUserID
        image = data["image"].stringValue
        imageWidth = data["image_width"].int32Value
        imageHeight = data["image_height"].int32Value
        audio = data["audio"].stringValue
        audioLength = data["audio_length"].doubleValue
        audioCaches = data["audio_wave_data"].stringValue
//        targetID = data["target_id"].int32Value
//        if targetID <= 0 {
//            throw SSModelError.IntegrityError
//        }
        messageType = data["message_type"].stringValue
        read = data["read"].boolValue
        if chatType == "user" {
            let userJSON = data["target_user"]
            relatedUser =  String(data: try! userJSON.rawData(), encoding: NSUTF8StringEncoding)
            _targetUser = try manager.getOrCreate(userJSON) as User
            targetID = _targetUser!.ssid
        } else if chatType == "club" {
            let clubJSON = data["target_club"]
            relatedClub = String(data: try! clubJSON.rawData(), encoding: NSUTF8StringEncoding)
            _targetClub = try! manager.getOrCreate(clubJSON) as Club
            targetID = _targetClub!.ssid
        } else {
            throw SSModelError.InvalidJSON
        }
        return self
    }
    
    func initForPost(messageType: String, textContent: String?, image: UIImage?, audio: NSURL?, relatedID: String? = nil) -> ChatRecord {
        self.messageType = messageType
        self.textContent = textContent
        self.mine = true
        self.createdAt = NSDate()
        contentImage = image
        imageWidth = Int32(image?.size.width ?? 0)
        imageHeight = Int32(image?.size.height ?? 0)
        return self
    }
    
    func confirmSent(newID: Int32, image: String?, audio: String?) -> Self{
        ssid = newID
        self.image = image
        self.audio = audio
        self.sent = true
        return self
    }
}
