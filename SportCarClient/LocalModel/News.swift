//
//  News.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class News: BaseInMemModel {
    override class var idField: String {
        return "newsID"
    }
    
    var coverURL: NSURL? {
        if cover == nil {
            return nil
        }
        return SFURL(cover!)
    }
    
    var contentURL: NSURL? {
        if content == nil {
            return nil
        }
        return NSURL(string: content!)
    }
    
    var commentNum: Int32 = 0
    var likeNum: Int32 = 0
    var cover: String!
    var content: String!
    var createdAt: NSDate!
    var recentLikeName: String?
    var shareNum: Int32 = 0
    var title: String!
    var liked: Bool = false
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> News {
        let json = JSON(data: string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        try loadDataFromJSON(json)
        return self
    }
    
    override func loadDataFromJSON(data: JSON) throws -> News {
        try super.loadDataFromJSON(data)
        ssid = data["id"].int32Value
        commentNum = data["comment_num"].int32Value
        cover = data["cover"].stringValue
        createdAt = DateSTR(data["created_at"].string)
        likeNum = data["like_num"].int32Value
        shareNum = data["share_num"].int32Value
        title = data["title"].stringValue
        content = data["content"].stringValue
        recentLikeName = data["recent_like_user_id"].stringValue
        liked = data["liked"].boolValue
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [
            "id": ssidString,
            "comment_num": "\(commentNum)",
            "cover": cover,
            "created_at": STRDate(createdAt),
            "like_num": "\(likeNum)",
            "share_num": "\(shareNum)",
            "title": title,
            "content": content,
            "recent_like_id": recentLikeName ?? "",
            "liked": liked
            ] as JSON
    }
    
    func getLikeDescription() -> NSAttributedString{
        return NSAttributedString(string: "")
    }
}
