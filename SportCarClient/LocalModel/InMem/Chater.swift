//
//  Chater.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class Chater: BaseInMemModel {
    
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
        try super.loadDataFromJSON(data)
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
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> Self {
        // TODO: finish this
//        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//        let json = JSON(data: data)
//        try self.loadDataFromJSON(json) as Chater
        return self
    }
}