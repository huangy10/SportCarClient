//
//  StatusComment.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON

class StatusComment: BaseInMemModel {
    
    override class var idField: String {
        return "commentID"
    }
    
    var status: Status
    
    var content: String!
    var createdAt: Date!
    var sent: Bool!
    var responseTo: StatusComment?
    var user: User!
    
    init(status: Status) {
        self.status = status
        super.init()
    }
    
    override func loadDataFromJSON(_ data: JSON) throws -> Self {
        try super.loadDataFromJSON(data)
        ssid = data["commentID"].int32Value
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        let userJSON = data["user"]
        let user: User = try status.manager.getOrCreate(userJSON) as User
        self.user = user
        let responseToJson = data["response_to"]
        if responseToJson.exists() {
            responseTo = try! StatusComment(status: self.status).loadDataFromJSON(responseToJson)
        }
        return self
    }
    
    func initForPost(_ content: String, responseTo: StatusComment?) -> Self {
        self.content = content
        self.responseTo = responseTo
        self.user = MainManager.sharedManager.hostUser
        self.createdAt = Date()
        self.sent = false
        return self
    }
    
    func confirmSent(_ newID: Int32) -> Self {
        self.sent = true
        self.ssid = newID
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        var json = [
            StatusComment.idField: ssidString,
            "content": content,
            "created_at": STRDate(createdAt),
        ] as JSON
        json["user"] = try! user.toJSONObject(0)
        json["status"] = try! status.toJSONObject(0)
        if let responseTo = responseTo {
            json["response_to"] = try responseTo.toJSONObject(detailLevel)
        }
        return json
    }
    override func fromJSONString(_ string: String, detailLevel: Int) throws -> StatusComment {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: data)
//            ssid = json["statusID"].int32Value
            try self.loadDataFromJSON(json)
            return self
        } else {
            throw SSModelError.invalidJSONString
        }
    }
    
    class override func fromJSONString(_ string: String, detailLevel: Int) throws -> StatusComment {
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: data)
            let status = try MainManager.sharedManager.getOrCreate(json["status"]) as Status
            let obj = try StatusComment(status: status).loadDataFromJSON(json)
            return obj
        } else {
            throw SSModelError.invalidJSONString
        }
    }
}
