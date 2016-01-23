//
//  StatusComment.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/24.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON


class StatusComment: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static let objects = StatusCommentManager()
    
    func loadDataFromJSON(json: JSON, status: Status) {
        if json["commentID"].stringValue != self.commentID {
            assertionFailure("Integrity Error")
        }
        content = json["content"].string
        createdAt = DateSTR(json["created_at"].stringValue)
        image = json["image"].string
        user = User.objects.create(json["user"]).value
        self.status = status
        
        // TODO: responseTo还没有处理
    }

}


class StatusCommentManager {
    
    let context = Status.objects.context
    
    var comments: [String: StatusComment] = [:]
    
    var unSentComments: [StatusComment] = []
    
    /**
     获取或者创建一条状态评论
     
     - parameter json:   json数据包
     - parameter status: 对应的状态
     
     - returns: 评论对象以及该对象是否是从内存中直接获取的
     */
    func getOrCreate(json: JSON, status: Status) -> (StatusComment, Bool){
        let commentID = json["commentID"].stringValue
        if let comment = comments[commentID] {
            return (comment, false)
        }
        let comment = context.statusComments.firstOrCreated({ $0.commentID == commentID})
        comment.loadDataFromJSON(json, status: status)
        return (comment, true)
    }
    
    /**
     批量创建状态评论
     
     - parameter jsons:  json数组
     - parameter status: 对应的状态
     
     - returns: 评论数组
     */
    func getOrCreateBatch(jsons: [JSON], status: Status) -> [StatusComment] {
        var result: [StatusComment] = []
        for json in jsons {
            result.append(getOrCreate(json, status: status).0)
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
    func postNewCommentToStatus(status: Status, commentString: String, responseToComment: StatusComment?, atString: String?) -> StatusComment {
        let hostUser = User.objects.hostUser!
        let newComment = context.statusComments.createEntity()
        newComment.createdAt = NSDate()
        newComment.user = hostUser
        newComment.content = commentString
        newComment.commentTo = responseToComment
        newComment.status = status
        newComment.atString = atString
        unSentComments.append(newComment)
        return newComment
    }
    
    /**
     确认一个评论已经发送完毕，需要进行的处理是将这个status的comment设置为sent，并将其从unSentComment的list已到字典内存池中
     
     - parameter comment: 目标评论对象
     - parameter commentID: 服务器分配给这个评论的内存
     */
    func confirmSent(comment: StatusComment, commentID: String) {
        if comment.alreadySent {
            return
        }
        comment.alreadySent = true
        comment.commentID = commentID
        unSentComments.remove(comment)
        comments[commentID] = comment
        
        do{
            try context.save()
        }catch _ {
            
        }
    }
    
}


