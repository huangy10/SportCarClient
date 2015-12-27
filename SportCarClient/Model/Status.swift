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
    /// Status的管理器
    static let objects = StatusManager()
}


// MARK: - Status对象的额外功能
extension Status {
    
    /**
     从给定的json数据中载入status数据
     
     - parameter json: json数据
     */
    func loadDataFromJSON(json: JSON) {
        content = json["content"].string
        createdAt = DateSTR(json["created_at"].string)
        image = json["image"].string
        likeNum = json["like_num"].int32 ?? 0
        commentNum = json["comment_num"].int32 ?? 0
        let location = json["location"]
        location_des = location["description"].string
        location_x = location["lon"].double ?? 0
        location_y = location["lat"].double ?? 0
        
        statusID = location["statusID"].string
    }
}

class StatusManager {
    /// 内存池中维持的状态集
    var status: [String: Status] = [:]
    
    let context = DataContext()
    
}




extension StatusManager {
    /**
     获取或者创建一个新的Status实例
     
     - parameter initial: 初始值，为空的时候忽略
     
     - returns: 返回一个二元组，第一个元素是获取或者生成的Status实例，第二个元素表征这个实例是否是生成的
     */
    func getOrCreateEmpty(statusID: String, initial: JSON? = nil) -> (Status?, Bool){
        if let s = status[statusID] {
            if initial != nil {
                s.loadDataFromJSON(initial!)
            }
            return (s, false)
        }
        if let s = context.statuses.first({$0.statusID == statusID}) {
            if initial != nil {
                s.loadDataFromJSON(initial!)
            }
            return (s, false)
        }else{
            let s = context.statuses.createEntity()
            s.statusID = statusID
            if initial != nil {
                s.loadDataFromJSON(initial!)
            }
            return (s, false)
        }
    }
    
    /**
     将当前context里面的内容全部保存
     
     - returns: 是否保存成功
     */
    func save() -> Bool {
        do {
            try context.save()
        }catch let err {
            print(err)
            return false
        }
        return true
    }
}



// MARK: - 这个扩展用来从内存中获取数据
extension StatusManager {
    
    /**
     根据也用户和跑车来检索状态
     
     - parameter user: 检索的用户
     - parameter car:  检索的车辆
     
     - returns: 返回查询结果
     */
    func statusList(forUser user: User?, aboutCar car: SportCar?) -> [Status]{
        return []
    }
    
    /**
     根据用户检索状态
     
     - parameter user: 检索的用户
     
     - returns: 返回检索到的结果
     */
    func statusList(forUser user: User) -> [Status] {
        return []
    }
}


