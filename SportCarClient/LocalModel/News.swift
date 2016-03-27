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
        return SFURL(content!)
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
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> Self {
        return self
    }
    
    override func loadDataFromJSON(data: JSON) throws -> Self {
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [] as JSON
    }
    
    func getLikeDescription() -> NSAttributedString{
        return NSAttributedString(string: "")
    }
}
