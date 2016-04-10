//
//  NewsComment.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewsComment: BaseInMemModel {
    override class var idField: String {
        return "commentID"
    }
    
    var content: String!
    var createdAt: NSDate!
    var sent: Bool!
    var responseTo: NewsComment?
    var user: User!
    
    var news: News
    
    init(news: News) {
        self.news = news
        super.init()
    }
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> NewsComment {
        let json = JSON(data: string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        try loadDataFromJSON(json)
        return self
    }
    
    override func loadDataFromJSON(data: JSON) throws -> NewsComment {
        try super.loadDataFromJSON(data)
        ssid = data["commentID"].int32Value
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        let userJSON = data["user"]
        let user: User = try MainManager.sharedManager.getOrCreate(userJSON)
        self.user = user
        // TODO: response to 
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [] as JSON
    }
}
