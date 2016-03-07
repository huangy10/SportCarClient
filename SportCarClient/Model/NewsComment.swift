//
//  NewsComment.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/26.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

class NewsComment: NSManagedObject {
    
    static let objects = NewsCommentManager()

    /**
     从JSON中载入数据，JSON的格式为：
     
        |- commentID:
        |- image:
        |- content:
        |- user:
            |- user_id
            |- nick_name
            |- avatar
        |- response_to: 可能为空
     
     - parameter json: json数据
     - parameter news: 被评论的news
     */
    func loadDataFronJSON(json: JSON, commentedNews: News) {
        content = json["content"].string
        image = json["image"].string
        createdAt = DateSTR(json["created_at"].string)
        if let commentToID = json["response_to__id"].string {
            commentTo = NewsComment.objects.getOrCreate(commentToID)
        }else{
            commentTo = nil
        }
        news = commentedNews
        let userJSON = json["user"]
        // 跨了context，需要处理一下
        let addUser = User.objects.create(userJSON).value
        user = self.managedObjectContext?.objectWithID(addUser!.objectID) as? User
    }
}


class NewsCommentManager {
    /// 本Manager使用的context，和news的manager使用同一个context
    var context : DataContext = News.objects.context
    
    /// 评论池
    var comments: [String: NewsComment] = [:]
    /// 尚未发布到的服务器的评论，故这里面的评论还并不具有服务器分配的id，故以数组形式储存。当发送成功以后对应的评论会被移出该list。正常网络情况下，评论对象只会在创建后和完成发送之间的很短时间内在这里驻留。当网络情况不佳时，所有未能提交给服务器的评论内容都会缓存在这里，当网络可以使用时再发送
    var unSentComments: [NewsComment] = []
    
    /**
     获取已经存在的评论内容或者创建新的，这个接口的设计是为了方便如下情形的使用
     
     从服务器获取的评论列表的数据里面包含了评论回应的目标评论的id，利用这个id获取被评论的评论对象
     
     - parameter commentID: comment的id
     
     - returns: Comment对象
     */
    func getOrCreate(commentID: String) -> NewsComment {
        if let comment = comments[commentID] {
            return comment
        }
        let newComment = context.newsComments.firstOrCreated( {$0.commentID == commentID} )
        comments[commentID] = newComment
        return newComment
    }
    
    /**
     对一组json组的数据处理，返回读取的comment对象数组
     
     - parameter jsons: json数组
     - parameter news:  对应的news
     
     - returns: comment对象数组
     */
    func createOrUpdate(jsons: [JSON], news: News) -> [NewsComment] {
        var result = [NewsComment]()
        for json in jsons {
            let commentID = json["commentID"].stringValue
            let newComment = NewsComment.objects.getOrCreate(commentID)
            newComment.loadDataFronJSON(json, commentedNews: news)
            result.append(newComment)
        }
        return result
    }
    
    /**
     发布一条新的评论，这条评论的发布者永远是当前的hostuser，所以这一参数并不用制定。由于这个对象
     
     - parameter news:              被评论的news对象
     - parameter commentString:     评论的内容
     - parameter responseToComment: 被回应的评论对象
     - parameter atString:          需要at的人的JSON编码的字符串，仅供缓存发送使用
     
     - returns: 返回创建成功的NewsComment对象
     */
    func postNewCommentToNews(news: News, commentString: String, responseToComment: NewsComment?, atString: String?, ctx: DataContext? = nil) -> NewsComment {
        // 获取当前context下hostUser对象
        let hostUser = User.objects.hostUser(ctx)
        let newComment = context.newsComments.createEntity()
        newComment.createdAt = NSDate()
        newComment.user = hostUser
        newComment.content = commentString
        newComment.commentTo = responseToComment
        newComment.news = news
        newComment.atString = atString
        unSentComments.append(newComment)
        return newComment
    }
    
    /**
     确认一个评论已经发送完毕，需要进行的处理是将这个news的comment设置为sent，并将其从unSentComment的list已到字典内存池中
     
     - parameter comment: 目标评论对象
     - parameter commentID: 服务器分配给这个评论的内存
     */
    func confirmSent(comment: NewsComment, commentID: String) {
        if comment.alreaySent {
            return
        }
        comment.alreaySent = true
        comment.commentID = commentID
        unSentComments.remove(comment)
        comments[commentID] = comment
    }
}
