//
//  Notification.swift
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

class Notification: NSManagedObject {
    
    static let objects = NotificationManager()
    
    /**
     从json中载入数据
     
     - parameter json: json数据格式
     */
    func loadFromJSON(json: JSON) {
        createdAt = DateSTR(json["created_at"].string)
        messageBody = json["message_body"].string
        messageType = json["message_type"].string
        read = json["read"].bool ?? true
        // TODO： 处理targetID
        let userJSON = json["related_user"]
        user = User.objects.create(userJSON, ctx: Notification.objects.context).value
        let statusJSON = json["related_status"]
        let status = Status.objects.getOrCreate(statusJSON).0!
        relatedID = status.statusID
        let statusImage = status.image!
        image = statusImage.split(";").first()
    }
    
}

class NotificationManager {
    
    let context = DataContext()
    
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
    
    func saveAll() -> Bool{
        do {
            try context.save()
            return false
        } catch {
            return true
        }
    }
    
}

