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
import Dollar

/*
概述：
这一文件是News模块的Model维持层

事实上，News模块较为独立的，较少有跨模块的数据一致性问题。故这一部分的API的作用主要在于DataPersistence
*/

class News: NSManagedObject {
    
    static let objects = NewsManager()
    
    // TODO: save this to core data
    /// 是否被当前用户赞了
    var liked = false

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
        shareNum = json["share_times"].int32 ?? 0
        title = json["title"].string
        contentURL = json["content"].string
        recentLikerName = json["recent_like_user_id"].stringValue
        liked = json["liked"].boolValue
    }
    
    func getLikeDescription() -> NSAttributedString{
        let host = User.objects.hostUser()!
        let currentLiked = host.isNewsLiked(self)
        
        let gray = UIColor(white: 0.72, alpha: 1)
        let red = kHighlightedRedTextColor
        let font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        var result: NSAttributedString
        if 0 == likeNum {
            result = NSAttributedString(string: LS("抢先来赞"), attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: gray])
        }else if recentLikerName == nil && !currentLiked{
            result = NSAttributedString(string: "\(likeNum)" + LS("人赞了"), attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: gray])
        }else if !currentLiked {
            let str = NSMutableAttributedString(string: "\(recentLikerName)\(LS("和其他"))\(likeNum-1)\(LS("人赞了"))", attributes: [NSFontAttributeName: font])
            str.addAttribute(NSForegroundColorAttributeName, value: red, range: NSMakeRange(0, recentLikerName!.length))
            str.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSMakeRange(recentLikerName!.length, str.length - recentLikerName!.length))
            result = str
        }else{
            let name = LS("你、") + recentLikerName!
            let str = NSMutableAttributedString(string: "\(name)\(LS("和其他"))\(likeNum-1)\(LS("人赞了"))", attributes: [NSFontAttributeName: font])
            str.addAttribute(NSForegroundColorAttributeName, value: red, range: NSMakeRange(0, name.length))
            str.addAttribute(NSForegroundColorAttributeName, value: gray, range: NSMakeRange(name.length, str.length - name.length))
            result = str
        }
        return result
    }
    
}


/// News的管理器
class NewsManager {
    /// 本Mananger使用的context
    let context = DataContext()
    //
    let privateContxt: DataContext
    /// 内存池内的news
    var news: [String: News] = [:]
    
    init() {
        privateContxt = DataContext(parentDataContext: context)
    }
    
    deinit {
        do {
            try context.save()
        } catch _ {
            assertionFailure()
        }
    }
}

// MARK: - JSON
extension NewsManager {
    
    /**
     创建的或者更新已有的news数据
     
     - parameter jsons: JSON数据，每个元素是一个新的新闻
     
     - return: 返回创建成功的news
     */
    func createOrUpdate(jsons: [JSON]) -> [News]{
        var result = [News]()
        for json in jsons {
            let newsID = "\(json["id"].stringValue)"
            if let n = news[newsID] {
                // 如果这一数据已经在内存中了，则更新之
                n.loadValueFromJSON(json)
                result.append(n)
                continue
            }
            // 如果没在内存池中，则尝试从coreData中读取，coreData中也没有则创建的之
            let n = context.news.firstOrCreated({$0.newsID == newsID})
            n.loadValueFromJSON(json)
            // 更新内存池
            news[newsID] = n
            result.append(n)
        }
        return result
    }
}

// MARK: - 过期数据清理
extension NewsManager {
    
    /**
     这个函数清理coreData中的内容，将不再内存池中的数据清除
     */
    func clearCoreData() {

        let newsIDs = Array(news.keys)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            let predicate = NSPredicate(format: "newsID NOT IN %@", newsIDs)
            do{
                try self.privateContxt.news.filterUsingPredicate(predicate).delete()
            }catch _ {
                assertionFailure()
            }
        })
    }
}