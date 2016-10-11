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
    
    var coverURL: URL? {
        if cover == nil {
            return nil
        }
        return SFURL(cover!)
    }
    
    var contentURL: URL? {
        if content == nil {
            return nil
        }
        return URL(string: content!)
    }
    
    var commentNum: Int32 = 0
    var likeNum: Int32 = 0
    var cover: String!
    var content: String!
    var createdAt: Date!
    var recentLikeName: String?
    var shareNum: Int32 = 0
    var title: String!
    var liked: Bool = false
    var isVideo: Bool = false
    
    override func fromJSONString(_ string: String, detailLevel: Int) throws -> News {
        let json = JSON(data: string.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        try loadDataFromJSON(json)
        return self
    }
    
    @discardableResult
    override func loadDataFromJSON(_ data: JSON) throws -> News {
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
        isVideo = data["is_video"].boolValue
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
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
        if let name = recentLikeName {
            let result = NSMutableAttributedString(string: "\(name)和其他\(likeNum - 1)人赞了")
            result.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], range: NSRange(location: 0, length: name.length))
            result.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kTextGray28], range: NSRange(location: name.length, length: result.length - name.length))
            return result
        } else {
            return NSAttributedString(string: LS("还没有人点赞"), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kTextGray28])
        }
    }
}
