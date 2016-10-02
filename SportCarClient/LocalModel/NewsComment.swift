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
    var createdAt: Date!
    var sent: Bool!
    var responseTo: NewsComment?
    var user: User!
    
    var news: News
    
    init(news: News) {
        self.news = news
        super.init()
    }
    
    @discardableResult
    override func fromJSONString(_ string: String, detailLevel: Int) throws -> NewsComment {
        let json = JSON(data: string.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        try loadDataFromJSON(json)
        return self
    }
    
//    class override func fromJSONString(string: String, detailLevel: Int) throws -> NewsComment {
//        if let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//            let json = JSON(data: data)
//            let news = try MainManager.sharedManager.getOrCreate(json["news"]) as News
//            let obj = try NewsComment(news: news).loadDataFromJSON(json)
//            return obj
//        } else {
//            throw SSModelError.InvalidJSONString
//        }
//    }
//    
    @discardableResult
    override func loadDataFromJSON(_ data: JSON) throws -> NewsComment {
        try super.loadDataFromJSON(data)
        ssid = data["commentID"].int32Value
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        let userJSON = data["user"]
        let user: User = try MainManager.sharedManager.getOrCreate(userJSON)
        self.user = user
        let responseToJson = data["response_to"]
        if responseToJson.exists() {
            responseTo = try! NewsComment(news: self.news).loadDataFromJSON(responseToJson)
        }
        return self
    }
    
    @discardableResult
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        return [] as JSON
    }
}
