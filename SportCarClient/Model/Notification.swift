//
//  Notification.swift
//

import Foundation
import CoreData
import SwiftyJSON

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
    }
    
}

class NotificationManager {
    
    let context = User.objects.context
    
    func getOrCreate(json: JSON) -> Notification?{
        return nil
    }
    
}

