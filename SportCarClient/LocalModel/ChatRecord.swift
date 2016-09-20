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
    
    fileprivate var _cachedWaveData: [Float]?
    var cachedWaveData: [Float]? {
        get {
            if _cachedWaveData == nil {
                if let cache = self.audioCaches {
                    let data = JSON(data: cache.data(using: String.Encoding.utf8, allowLossyConversion: false)!).arrayValue
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
    
    fileprivate var _senderUser: User?
    
    var senderUser : User? {
        if mine {
            return manager.hostUser
        }
        assert(sender != nil, "No sender for chat")
        if _senderUser == nil {
            let json = JSON(data: sender!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            _senderUser = try! manager.getOrCreate(json, detailLevel: 0) as User
        }
        return _senderUser
    }
    
    var imageSize: CGSize! {
        return CGSize(width: CGFloat(imageWidth), height: CGFloat(imageHeight))
    }
    
    var imageURL: URL! {
        return SFURL(image!)!
    }
    
    var contentImage: UIImage?
    
    fileprivate var _targetUser: User?
    var targetUser: User? {
        get {
            assert(relatedUser != nil, "")
            if _targetUser == nil {
                let json = JSON(data: relatedUser!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
                _targetUser = try! manager.getOrCreate(json) as User
            }
            return _targetUser
        }
        set {
            _targetUser = newValue
            relatedUser = try! _targetUser?.toJSONString(0)
        }
    }
    
    fileprivate var _targetClub: Club?
    var targetClub: Club? {
        get {
            assert(relatedClub != nil, "")
            if _targetClub == nil {
                let json = JSON(data: relatedClub!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
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

    override func loadDataFromJSON(_ data: JSON, detailLevel: Int, forceMainThread: Bool = false) throws -> ChatRecord {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        rosterID = data["roster"]["ssid"].int32Value
        createdAt = DateSTR(data["created_at"].stringValue)
        chatType = data["chat_type"].stringValue
        textContent = data["text"].stringValue
        let userJSON = data["sender"]
        sender = userJSON.rawString()
        _senderUser = try! manager.getOrCreate(userJSON) as User
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
            relatedUser =  String(data: try! userJSON.rawData(), encoding: String.Encoding.utf8)
            _targetUser = try manager.getOrCreate(userJSON) as User
            targetID = _targetUser!.ssid
        } else if chatType == "club" {
            let clubJSON = data["target_club"]
            relatedClub = String(data: try! clubJSON.rawData(), encoding: String.Encoding.utf8)
            _targetClub = try! manager.getOrCreate(clubJSON) as Club
            targetID = _targetClub!.ssid
        } else {
            throw SSModelError.invalidJSON
        }
        return self
    }
    
    func initForPost(_ messageType: String, textContent: String?, image: UIImage?, audio: URL?, relatedID: String? = nil) -> ChatRecord {
        self.messageType = messageType
        self.textContent = textContent
        self.mine = true
        self.createdAt = Date()
        contentImage = image
        imageWidth = Int32(image?.size.width ?? 0)
        imageHeight = Int32(image?.size.height ?? 0)
        return self
    }
    
    func confirmSent(_ newID: Int32, image: String?, audio: String?) -> Self{
        ssid = newID
        self.image = image
        self.audio = audio
        self.sent = true
        return self
    }
}
