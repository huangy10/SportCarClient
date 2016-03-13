//
//  Notification.swift
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

class Notification: NSManagedObject {
    
    static let objects = NotificationManager()
    
    var relatedObject: NSManagedObject?
    
    /**
     从json中载入数据
     
     - parameter json: json数据格式
     */
    func loadFromJSON(json: JSON) {
        
        let context = Notification.objects.context
        
        createdAt = DateSTR(json["created_at"].string)
        messageBody = json["message_body"].string
        messageType = json["message_type"].string
        read = json["read"].bool ?? true
        flag = json["flag"].bool ?? false
        // TODO： 处理targetID
        switch messageType! {
        case "status_like":
            // some one like one of your statuses
            let userJSON = json["related_user"]
            user = User.objects.getOrCreate(userJSON, ctx: context)
            let statusJSON = json["related_status"]
            let status = Status.objects.getOrCreate(statusJSON, ctx: context)
            relatedID = status.statusID
            relatedObject = status
            let statusImage = status.image!
            image = statusImage.split(";").first()

        case "status_comment":
            // some one comments on your status
            let statusJSON = json["related_status"]
            let status = Status.objects.getOrCreate(statusJSON, ctx: context)
            let statusCommentJSON = json["related_status_comment"]
            let statusComment = StatusComment.objects.getOrCreate(statusCommentJSON, status: status, ctx: context)
            relatedID = statusComment.commentID
            relatedObject = statusComment
            user = statusComment.user
            messageBody = statusComment.content
            let statusImage = status.image
            image = statusImage?.split(";").first()
            
        case "status_comment_replied":
            // some one replies your comments below a status of another user
            let statusJSON = json["related_status"]
            let status = Status.objects.getOrCreate(statusJSON, ctx: context)
            let statusCommentJSON = json["related_status_comment"]
            let statusComment = StatusComment.objects.getOrCreate(statusCommentJSON, status: status, ctx: context)
            relatedID = statusComment.commentID
            relatedObject = statusComment
            user = statusComment.user
            messageBody = statusComment.content
            let statusImage = status.image
            image = statusImage?.split(";").first()
        
        case "relation_follow":
            let userJSON = json["related_user"]
            user = User.objects.getOrCreate(userJSON, ctx: context)
            
        case "status_inform":
            // someone at you when post his/her new status
            let statusJSON = json["related_status"]
            let status = Status.objects.getOrCreate(statusJSON, ctx: context)
            user = status.user
            relatedID = status.statusID
            relatedObject = status
            image = status.coverImage
            
        case "act_applied":
            // someone tries to apply your activity
            let actJSON = json["related_act"]
            let act = Activity.objects.getOrCreate(actJSON, ctx: context)
            let userJSON = json["related_user"]
            user = User.objects.getOrCreate(userJSON, ctx: context)
            relatedObject = act
            relatedID = act.activityID
            image = act.poster
            break
        
        case "act_denied":
            let actJSON = json["related_act"]
            let act = Activity.objects.getOrCreate(actJSON, ctx: context)
            user = act.user
            relatedID = act.activityID
            relatedObject = act
            image = act.poster
        
        case "act_invited", "act_invitation_accepted":
            let actJSON = json["related_act"]
            let act = Activity.objects.getOrCreate(actJSON, ctx: context)
            relatedID = act.activityID
            relatedObject = act
            let userJSON = json["related_user"]
            user = User.objects.getOrCreate(userJSON, ctx: context)
//        
//        case "act_invitation_accepted":
//            let actJSON = json["related_act"]
//            let act = Activity.objects.getOrCreate(actJSON, ctx: context)
//            user = act.user
//            relatedID = act.activityID
//            relatedObject = act
//            image = act.poster
//            break
//            
        default:
            print(json)
            assertionFailure()
        }
    }
}

// MARK: - Getter to get status belongs to main context
extension Notification {
    
    func getRelatedObject<T>(ctx: DataContext? = nil) -> T? {
        if relatedObject == nil {
            return nil
        }
        let context = ctx ?? User.objects.defaultContext
        return context.objectWithID(relatedObject!.objectID) as? T
    }
    
}

class NotificationManager {
    
    let context = DataContext(parentDataContext: User.objects.defaultContext)
    
    func getOrCreate(json: JSON) -> Notification?{
        let notificationID = json["notification_id"].stringValue
        if notificationID == "" {
            // blank id is not allowed
            return nil
        }
        let notification = context.notifications.firstOrCreated({$0.notificationID == notificationID})
        notification.loadFromJSON(json)
        return notification
    }
    
    func historicalList(limit: Int) -> [Notification] {
        var notifs = context.notifications.orderByDescending({$0.createdAt}).take(limit).toArray()
        notifs = notifs.each { (notif) -> () in
            let messageType = notif.messageType!
            let messageElement = messageType.split("_")
            var modelType = ""
            if messageElement[1] == "comment" {
                modelType = messageElement[0] + messageElement[1]
            } else {
                modelType = messageElement[0]
            }
            switch modelType {
            case "act":
                notif.relatedObject = self.context.activities.first {$0.activityID == notif.relatedID}
            case "status":
                notif.relatedObject = self.context.statuses.first {$0.statusID == notif.relatedID}
            case "status_comment":
                notif.relatedObject = self.context.statusComments.first {$0.commentID == notif.relatedID}
            default:
                break
            }
        }
        return notifs
    }
    
    func saveAll() -> Bool{
        do {
            try context.save()
            return false
        } catch {
            return true
        }
    }
    
}

