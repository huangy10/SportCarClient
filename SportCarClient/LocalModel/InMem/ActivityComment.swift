//
//  ActivityComment.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActivityComment: BaseInMemModel {
    
    override class var idField: String {
        return "commentID"
    }
    
    var act: Activity
    
    var content: String!
    var createdAt: NSDate!
    var sent: Bool!
    var responseTo: ActivityComment?
    var user: User!
    
    init(act: Activity) {
        self.act = act
        super.init()
    }
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> ActivityComment {
        // ignore detailLevel
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: data)
            ssid = json["actID"].int32Value
            try loadDataFromJSON(json)
            return self
        } else {
            throw SSModelError.InvalidJSONString
        }
    }
    
    class override func fromJSONString(string: String, detailLevel: Int) throws -> ActivityComment {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let json = JSON(data: data)
            let act = try MainManager.sharedManager.getOrCreate(json["activity"]) as Activity
            let obj = try ActivityComment(act: act).loadDataFromJSON(json)
            return obj
        } else {
            throw SSModelError.InvalidJSONString
        }
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        var json = [
            "commentID": ssidString,
            "content": content,
            "created_at": STRDate(createdAt),
        ] as JSON
        json["user"] = try user.toJSONObject(0)
        json["activity"] = try act.toJSONObject(0)
        if let responseTo = responseTo {
            json["response_to"] = try responseTo.toJSONObject(detailLevel)
        }
        return json
    }
    
    override func loadDataFromJSON(data: JSON) throws -> ActivityComment {
        try super.loadDataFromJSON(data)
        ssid = data["commentID"].int32Value
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        let userJSON = data["user"]
        let user: User = try act.manager.getOrCreate(userJSON)
        self.user = user
        let responseToJson = data["response_to"]
        if responseToJson.exists() {
            responseTo = try! ActivityComment(act: self.act).loadDataFromJSON(responseToJson)
        }
        return self
    }
    
    func initForPost(content: String, responseTo: ActivityComment?) -> ActivityComment {
        self.content = content
        self.responseTo = responseTo
        self.user = act.manager.hostUser
        self.sent = false
        self.createdAt = NSDate()
        return self
    }
    
    func confirmSent(newID: Int32) -> ActivityComment {
        self.sent = true
        self.ssid = newID
        return self
    }
}
