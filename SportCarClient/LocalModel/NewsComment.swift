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
    
    override func fromJSONString(string: String, detailLevel: Int) throws -> Self {
        return self
    }
    
    override func loadDataFromJSON(data: JSON) throws -> Self {
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [] as JSON
    }
}
