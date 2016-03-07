//
//  Club.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/22.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON


class Club: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static let objects = ClubManager()
    // 实质是关于俱乐部的配置，如果为空表示均为默认设置
    var clubJoining: ClubJoining?
    
    /**
     从json数据载入数据，这里面只载入最简单的几个属性
     
     - parameter json: json数据
     */
    func loadValueFromJSON(json: JSON, ctx: DataContext? = nil) {
        name = json["club_name"].string
        logo_url = json["club_logo"].string
        clubDescription = json["description"].string
        identified = json["identified"].boolValue
        city = json["city"].string
        let hostJson = json["host"]
        if hostJson["userID"].stringValue != "" {
            host = User.objects.create(hostJson, ctx: ctx).value
        }
        let memberNum = json["members_num"].int32Value
        if memberNum > 0 {
            self.memberNum = memberNum
        }
        if let showMembers = json["show_members_to_public"].bool {
            show_members = showMembers
        }
    }
}


class ClubManager {
    
    let defaultContext = User.objects.defaultContext
    
    func saveAll(context: DataContext) {
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
    /**
     获取内存中或者coredata中存储的数据或者创建新的记录
     
     - parameter json: json数据
     
     - returns: Club
     */
    func getOrCreate(json: JSON, ctx: DataContext? = nil) -> Club?{
        let context = ctx ?? defaultContext
        let clubID = json["id"].stringValue
        if clubID == "" {
            return nil
        }
        let club = context.clubs.firstOrCreated { $0.clubID == clubID }
        club.loadValueFromJSON(json, ctx: context)
        club.clubJoining = context.clubJoinings.firstOrCreated({$0.clubID == clubID})
        // saveAll()
        return club
    }
    
    /**
     从内存池或者是coredata中载入数据
     
     - parameter clubID: 俱乐部id
     
     - returns: 返回club对象
     */
    func getOrLoad(clubID: String, ctx: DataContext? = nil) -> Club? {
        let context = ctx ?? defaultContext
        let club = context.clubs.first { $0.clubID == clubID }
        if club != nil {
            club?.clubJoining = context.clubJoinings.firstOrCreated({$0.clubID == clubID})
        }
        return club
    }
    
}