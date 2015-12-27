//
//  News.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/26.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON


class News: NSManagedObject {
    
    static let objects = NewsManager()

}

extension News {
    
    /**
     从JSON数据中读取数据
     
     - parameter json: json
     */
    func loadValueFromJSON(json: JSON) {
        commentNum = json["comment_num"].int32Value
        cover = json["cover"].string
        createdAt = DateSTR(json["created_at"].string)
        likeNum = json["like_num"].int32Value
        shareNum = json["share_num"].int32 ?? 0
        title = json["title"].string
    }
    
}


/// News的管理器
class NewsManager {
    /// 本Mananger使用的context
    let context = DataContext()
    /// 内存池内的news
    var news: [String: News] = [:]
}

extension NewsManager {
    /**
     创建或者更新已有的news数据
     */
    func createOrUpdate() {
        
    }
}