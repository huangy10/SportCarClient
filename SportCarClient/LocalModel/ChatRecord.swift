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
    
    var cachedWaveData: [Float]?
    var displayTimeMark: Bool = false
    
    private var _senderUser: Chater?
    var senderUser : Chater? {
        if mine {
            return manager.hostUser?.toChatter()
        }
        assert(sender != nil, "No sender for chat")
        if _senderUser == nil {
            let json = JSON(data: sender!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            _senderUser = try! Chater().loadDataFromJSON(json)
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
            // TODO: set the related club at the same time
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
        createdAt = DateSTR(data["created_at"].stringValue)
        chatType = data["chat_type"].stringValue
        textContent = data["text_content"].string
        let userJSON = data["sender"]
        sender = userJSON.rawString()
        _senderUser = try Chater().loadDataFromJSON(userJSON)
        mine = _senderUser?.ssid == manager.hostUserID
        image = data["image"].stringValue
        imageWidth = data["image_width"].int32Value
        imageHeight = data["image_height"].int32Value
        audio = data["audio"].stringValue
        targetID = data["target_id"].int32Value
        if targetID <= 0 {
            throw SSModelError.IntegrityError
        }
        messageType = data["message_type"].stringValue
        read = data["read"].boolValue
        if chatType == "private" {
            let userJSON = data["target_user"]
            relatedUser =  String(data: try! userJSON.rawData(), encoding: NSUTF8StringEncoding)
            _targetUser = try manager.getOrCreate(userJSON) as User
        } else if chatType == "group" {
            let clubJSON = data["target_club"]
            relatedClub = String(data: try! clubJSON.rawData(), encoding: NSUTF8StringEncoding)
            _targetClub = try! manager.getOrCreate(clubJSON) as Club
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
        self.audioLocal = audio?.absoluteString
        contentImage = image
        imageWidth = Int32(image?.size.width ?? 0)
        imageHeight = Int32(image?.size.height ?? 0)
        return self
    }
    
    func confirmSent(newID: Int32, image: String?, audio: String?) -> Self{
        ssid = newID
        self.image = image
        self.audio = audio
        // TODO: sent
        return self
    }
}
