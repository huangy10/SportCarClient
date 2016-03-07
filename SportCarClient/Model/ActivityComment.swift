//
//  ActivityComment.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON


class ActivityComment: NSManagedObject {
    
    static let objects = ActivityCommentManager()

// Insert code here to add functionality to your managed object subclass
    func loadDataFromJSON(json: JSON, act: Activity) {
        content = json["content"].string
        createdAt = DateSTR(json["created_at"].string)
        image = json["image"].string
        user = User.objects.create(json["user"]).value
        self.activity = act
    }

}

class ActivityCommentManager {
    let context = Activity.objects.context
    
    /// 未发送成功的评论
    var unSentComments: [ActivityComment] = []
    
    func create(json: JSON, act: Activity) -> ActivityComment{
        let commentID = json["commentID"].stringValue
        let comment = context.activityComments.firstOrCreated {$0.commentID == commentID}
        comment.loadDataFromJSON(json, act: act)
        save()
        return comment
    }
    
    func postToNewCommentToActivity(act:Activity, commentString: String, atString: String?, responseToComment: ActivityComment?, ctx: DataContext? = nil) -> ActivityComment{
        let hostUser = User.objects.hostUser(ctx)
        let newComment = context.activityComments.createEntity()
        newComment.createdAt = NSDate()
        newComment.user = hostUser
        newComment.content = commentString
        newComment.activity = act
        newComment.atString = atString
        newComment.responseTo = responseToComment
        unSentComments.append(newComment)
        save()
        return newComment
    }
    
    func confirmSent(comment: ActivityComment, commentID: String) {
        if comment.sent {
            return
        }
        comment.sent = true
        comment.commentID = commentID
        unSentComments.remove(comment)
        save()
    }
    
    func save() -> Bool {
        do{
            try context.save()
            return true
        }catch _ {
            return false
        }
    }
}
