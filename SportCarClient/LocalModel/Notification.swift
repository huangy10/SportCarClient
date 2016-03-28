//
//  Notification.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData


class Notification: BaseModel {
    
    override class var idField: String {
        return "notification_id"
    }

    override func loadDataFromJSON(data: JSON, detailLevel: Int, forceMainThread: Bool) throws -> Self {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        createdAt = DateSTR(data["created_at"].stringValue)
        messageBody = data["message_body"].stringValue
        messageType = data["message_type"].stringValue
        read = data["read"].boolValue
        flag = data["flag"].boolValue
        let userJSON = data["related_user"]
        if userJSON.isExists() {
            user = try manager.getOrCreate(userJSON, detailLevel: 0) as User
        }
        let clubJSON = data["related_club"]
        if clubJSON.isExists() {
            _obj = try manager.getOrCreate(data) as Club
        }
        let newsJSON = data["related_news"]
        if newsJSON.isExists() {
            let news = try News().loadDataFromJSON(newsJSON)
            let commentJSON = data["related_news_comment"]
            if commentJSON.isExists() {
                let comment = try NewsComment(news: news).loadDataFromJSON(commentJSON)
                user = comment.user
                _objInMem = comment
            } else {
                _objInMem = news
            }
        }
        let statusJSON = data["related_status"]
        if statusJSON.isExists() {
            let status = try manager.getOrCreate(statusJSON) as Status
            let commentJSON = data["related_status_comment"]
            if commentJSON.isExists() {
                let comment = try StatusComment(status: status).loadDataFromJSON(commentJSON)
                _objInMem = comment
                user = comment.user
            } else {
                _obj = status
            }
        }
        let activityJSON = data["related_act"]
        if activityJSON.isExists() {
            let act = try manager.getOrCreate(activityJSON) as Activity
            let commentJSON = data["related_act_comment"]
            if commentJSON.isExists() {
                let comment = try ActivityComment(act: act).loadDataFromJSON(commentJSON)
                _objInMem = comment
                user = comment.user
            } else {
                _obj = act
            }
        }
        if _objInMem != nil {
            relatedObj = try _objInMem?.toJSONString(0)
        } else if _obj != nil{
            relatedObj = try _obj?.toJSONString(0)
        }
        return self
    }
    
    private var _obj: BaseModel?
    private var _objInMem: BaseInMemModel?
    
    func getRelatedObj<T: BaseModel>() throws -> T? {
        if relatedObj == nil {
            return nil
        }
        if _obj == nil {
            let temp: T = try manager.createNew()
            try _obj = temp.fromJSONString(relatedObj!, detailLevel: 0)
        }
        return _obj as? T
    }
    
    func getRelatedObj<T: BaseInMemModel>() throws -> T? {
        if relatedObj == nil {
            return nil
        }
        if _objInMem == nil {
            try _objInMem = T.fromJSONString(relatedObj!, detailLevel: 0)
        }
        return _objInMem as? T
    }
    
    class func loadHistoricalList(limit: Int) -> [Notification] {
        let context = NotificationModelManager.sharedManager.getOperationContext()
        let notifs = context.notifications.filter({$0.hostSSID == NotificationModelManager.sharedManager.hostUserID!}).orderByDescending({$0.createdAt}).take(limit).toArray()
        return notifs
    }
}
