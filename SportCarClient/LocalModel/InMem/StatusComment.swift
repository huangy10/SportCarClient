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
    var createdAt: NSDate!
    var sent: Bool!
    var responseTo: StatusComment?
    var user: User!
    
    init(status: Status) {
        self.status = status
        super.init()
    }
    
    override func loadDataFromJSON(data: JSON) throws -> Self {
        try super.loadDataFromJSON(data)
        ssid = data["commentID"].int32Value
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        let userJSON = data["user"]
        let user: User = try status.manager.getOrCreate(userJSON) as User
        self.user = user
        // TODO: response to
        
        return self
    }
    
    func initForPost(content: String, responseTo: StatusComment?) -> Self {
        self.content = content
        self.responseTo = responseTo
        self.user = MainManager.sharedManager.hostUser
        self.createdAt = NSDate()
        self.sent = false
        return self
    }
    
    func confirmSent(newID: Int32) -> Self {
        self.sent = true
        self.ssid = newID
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        var json = [
            StatusComment.idField: ssidString,
            "content": content,
            "created_at": STRDate(createdAt),
        ] as JSON
        json["user"] = try! user.toJSONObject(0)
        json["status"] = try! status.toJSONObject(0)
        return json
    }
//    override func fromJSONString(string: String, detailLevel: Int) throws -> Self{
//        if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//            let json = JSON(data: data)
//            ssid = json["statusID"].int32Value
//            try loadDataFromJSON(json)
//            return self
//        } else {
//            throw SSModelError.InvalidJSONString
//        }
//    }
}