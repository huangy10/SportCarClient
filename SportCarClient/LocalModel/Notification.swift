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
    
    var simplifiedMessageType: String {
        get {
            let elements = messageType!.split(delimiter: ":")
            return elements[1..<elements.count].joined(separator: ":")
        }
    }
    
    override class var idField: String {
        return "notification_id"
    }
    
    var imageURL: URL? {
        if image == nil {
            return nil
        }
        return SFURL(image!)
    }
    
    override func managerDidSet() {
        user?.manager = manager
        _obj?.manager = manager
    }

    override func loadDataFromJSON(_ data: JSON, detailLevel: Int, forceMainThread: Bool) throws -> Self {
        let _ = try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        createdAt = DateSTR(data["created_at"].stringValue)
        messageBody = data["message_body"].stringValue
        messageType = data["message_type"].stringValue
        read = data["read"].boolValue
        flag = data["flag"].boolValue
        checked = data["checked"].boolValue
        let userJSON = data["related_user"]
        if userJSON.exists() {
            user = try manager.getOrCreate(userJSON, detailLevel: 0) as User
        }
        let clubJSON = data["related_club"]
        if clubJSON.exists() {
            let club = try manager.getOrCreate(clubJSON) as Club
            image = club.logo
            _obj = club
        }
        let newsJSON = data["related_news"]
        if newsJSON.exists() {
            let news = try News().loadDataFromJSON(newsJSON)
            image = news.cover
            
            let commentJSON = data["related_news_comment"]
            if commentJSON.exists() {
                let comment = try NewsComment(news: news).loadDataFromJSON(commentJSON)
                messageBody = comment.content
                user = comment.user
                _objInMem = comment
            } else {
                _objInMem = news
            }
        }
        let statusJSON = data["related_status"]
        if statusJSON.exists() {
            let status = try manager.getOrCreate(statusJSON) as Status
//            messageBody = status.content
            image = status.image
            
            if user == nil {
                user = status.user
            }
            let commentJSON = data["related_status_comment"]
            if commentJSON.exists() {
                let comment = try StatusComment(status: status).loadDataFromJSON(commentJSON)
                _objInMem = comment
                messageBody = comment.content
                user = comment.user
            } else {
                _obj = status
            }
        }
        let activityJSON = data["related_act"]
        if activityJSON.exists() {
            let act = try manager.getOrCreate(activityJSON) as Activity
            messageBody = ""
            image = act.poster
            if user == nil {
                user = act.user
            }
            let commentJSON = data["related_act_comment"]
            if commentJSON.exists() {
                let comment = try ActivityComment(act: act).loadDataFromJSON(commentJSON)
                _objInMem = comment
                user = comment.user
                messageBody = comment.content
            } else {
                _obj = act
            }
        }
        let carJSON = data["related_own"]
        if carJSON.exists() {
            let car = try manager.getOrCreate(carJSON) as SportCar
            messageBody = ""
            image = nil
            _obj = car
        }
        if _objInMem != nil {
            relatedObj = try _objInMem?.toJSONString(0)
        } else if _obj != nil{
            relatedObj = try _obj?.toJSONString(0)
        }
        return self
    }
    
    fileprivate var _obj: BaseModel?
    fileprivate var _objInMem: BaseInMemModel?
    
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
    
    func makeDisplayTitlePhrases() -> [String] {
        let username = user!.nickName!
        switch simplifiedMessageType {
        case "User:like":
            return [username, "关注了你"]
        case "Status:like":
            return [username, "赞了你的动态"]
        case "Status:at":
            return [username, "在状态中提到了你"]
        case "StatusComment:at":
            return [username, "在状态评论中提到了你"]
        case "StatusComment:response":
            return [username, "在状态中回复了你"]
            
        case "ActivityJoin:invited":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "邀请你参加", activity.name!]
        case "ActivityJoin:invite_agreed":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "接受了你关于活动", activity.name!, "的申请"]
        case "ActivityJoin:invite_denied":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "拒绝了你对活动", activity.name!, "的申请"]
        case "ActivityJoin:kick_out":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "将你请出了活动", activity.name!]
        case "Activity:like":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "赞了你的活动", activity.name!]
        case "ActivityJoin:apply":
            let activity = try! getRelatedObj()! as Activity
            return [user!.nickName!, "报名了你发起的活动", activity.name!]
        case "ClubJoining:apply":
            let club = try! getRelatedObj()! as Club
            return [user!.nickName!, "申请加入你的俱乐部", club.name!]
        case "ClubJoining:agree":
            let club = try! getRelatedObj()! as Club
            return [user!.nickName!, "通过了你对俱乐部", club.name!, "的申请"]
        case "ClubJoining:deny":
            let club = try! getRelatedObj()! as Club
            return [user!.nickName!, "拒绝了你对俱乐部", club.name!, "的申请"]
        case "ActivityComment:at":
            return [username, "在评论中提到了你"]
        case "ActivityComment:response":
            return [username, "在活动中回复了你"]
        case "SportCarIdentificationRequestRecord:agree":
            let own = try! getRelatedObj()! as SportCar
            return [own.name!, " 的认证申请已经通过"]
        case "SportCarIdentificationRequestRecord:deny":
            let own = try! getRelatedObj()! as SportCar
            return [own.name!, " 的认证申请被拒绝"]
        default:
            print(simplifiedMessageType)
            return ["没有定义的消息类型"]
        }
    }
    
    lazy var displayModeMap: [String: NotificationCell.DisplayMode] = {
        return [
            "minimal": NotificationCell.DisplayMode.minimal,
            "with_cover": NotificationCell.DisplayMode.withCover,
            "interact": NotificationCell.DisplayMode.interact
        ]
    }()
    
    func getDisplayMode() -> NotificationCell.DisplayMode {
        let elements = messageType!.split(delimiter: ":")
        let displayModeString = elements[0]
        
        return displayModeMap[displayModeString] ?? .minimal
    }
}
