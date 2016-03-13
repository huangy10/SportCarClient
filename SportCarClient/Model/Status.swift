//
//  Status.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/24.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

class Status: NSManagedObject {
    
    /// TODO: save this to core data
    var liked = false
    
    /// Status的管理器
    static let objects = StatusManager()
    
    var coverImage: String? {
        return image?.split(";").first()
    }
}


// MARK: - Status对象的额外功能
extension Status {
    
    /**
     从给定的json数据中载入status数据
     
     - parameter json: json数据
     */
    func loadDataFromJSON(json: JSON, ctx: DataContext? = nil) {
        if json["statusID"].stringValue != self.statusID! {
            assertionFailure("Integrity Error")
        }
        let context = ctx ?? Status.objects.defaultContext
        self.content = json["content"].string
        self.createdAt = DateSTR(json["created_at"].stringValue)
        self.image = json["images"].string
        self.likeNum = json["like_num"].int32 ?? 0
        self.liked = json["liked"].boolValue
        self.commentNum = json["comment_num"].int32 ?? 0
        let locationJSON = json["location"]
        self.location_x = locationJSON["lon"].double ?? 0
        self.location_y = locationJSON["lat"].double ?? 0
        self.location_des = locationJSON["description"].string
        
        let carJSON = json["car"]
        if !carJSON.isEmpty {
            car = SportCar.objects.getOrCreate(carJSON, ctx: context)
        }
        let userJSON = json["user"]
        user = User.objects.getOrCreate(userJSON, ctx: context)
    }
}

class StatusManager {
    
    let defaultContext = User.objects.defaultContext
}




extension StatusManager {
    
    /**
     这个函数处理由Status首页返回的JSON编码数据
     
     - parameter json: JSON数据
     
     - returns: 返回生成的状态，以及这个状态是否是构造的
     */
    func getOrCreate(json: JSON, ctx: DataContext? = nil) -> Status{
        let context = ctx ?? defaultContext
        let statusID = json["statusID"].stringValue
        assert(statusID != "")
        let s = context.statuses.firstOrCreated({ $0.statusID == statusID })
        s.loadDataFromJSON(json, ctx: context)
        return s
    }
    /**
     获取或者创建一个新的Status实例
     
     - parameter initial: 初始值，为空的时候忽略
     
     - returns: 返回一个二元组，第一个元素是获取或者生成的Status实例，第二个元素表征这个实例是否是生成的
     */
    func getOrCreateEmpty(statusID: String, initial: JSON? = nil, ctx: DataContext? = nil) -> (Status?, Bool){
        let context = ctx ?? defaultContext
        
        if let s = context.statuses.first({$0.statusID == statusID}) {
            if initial != nil {
                s.loadDataFromJSON(initial!, ctx: context)
            }
            return (s, false)
        }else{
            let s = context.statuses.createEntity()
            s.statusID = statusID
            if initial != nil {
                s.loadDataFromJSON(initial!, ctx: context)
            }
            return (s, false)
        }
    }
}

