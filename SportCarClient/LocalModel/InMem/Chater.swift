//
//  Chater.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlecrimCoreData


class Chater: BaseInMemModel {
    
    weak var chat: ChatRecord?
    
    var isHost: Bool {
        return ssid == MainManager.sharedManager.hostUserID
    }
    
    var avatarURL: NSURL? {
        if avatar == nil {
            return nil
        }
        return SFURL(avatar!)
    }
    
    var avatar: String!
    var nickName: String!
    
    override func loadDataFromJSON(data: JSON) throws -> Self {
//        try super.loadDataFromJSON(data)
        ssid = data[User.idField].int32Value
        nickName = data["nick_name"].stringValue
        avatar = data["avatar"].stringValue
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [
            User.idField: ssidString,
            "nick_name": nickName!,
            "avatar": avatar!
        ]
    }
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> Chater {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let json = JSON(data: data)
        try self.loadDataFromJSON(json)
        return self
    }
    
    private var _user: User?
    func toUser() -> User? {
        if let user = _user {
            return user
        }
        if let manager = chat?.manager {
            _user = try! manager.getOrCreate(try! toJSONObject(0), detailLevel: 0) as User
            return _user
        } else {
            if NSThread.isMainThread() {
                _user = try! MainManager.sharedManager.getOrCreate(try! toJSONObject(0), detailLevel: 0) as User
                return _user
            } else {
                _user = try! ChatModelManger.sharedManager.getOrCreate(try! toJSONObject(0), detailLevel: 0) as User
                return _user
            }
        }
    }
    
    func relatedUser() -> User? {
        var context: DataContext! = nil
        if self.chat != nil {
            context = self.chat?.manager.getOperationContext()
        } else if NSThread.isMainThread() {
            context = MainManager.sharedManager.getOperationContext()
        } else {
            context = ChatModelManger.sharedManager.getOperationContext()
        }
        if let targetUser = context.users.first({$0.ssid == self.ssid}) {
            return targetUser
        } else {
            return self.toUser()
        }
    }
}