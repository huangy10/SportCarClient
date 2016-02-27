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
    
    /**
     从json数据载入数据，这里面只载入最简单的几个属性
     
     - parameter json: json数据
     */
    func loadValueFromJSON(json: JSON) {
        name = json["club_name"].string
        logo_url = json["club_logo"].string
        clubDescription = json["description"].string
    }
    
}


class ClubManager {
    
    let context = User.objects.context
    
    func saveAll() {
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
    
    var clubs: [String: Club] = [:]
    /**
     获取内存中或者coredata中存储的数据或者创建新的记录
     
     - parameter json: json数据
     
     - returns: Club
     */
    func getOrCreate(json: JSON) -> Club?{
        let clubID = json["id"].stringValue
        if let club = self.clubs[clubID] {
            club.loadValueFromJSON(json)
            return club
        }
        let club = context.clubs.firstOrCreated { $0.clubID == clubID }
        club.loadValueFromJSON(json)
        self.clubs[clubID] = club
        return club
    }
    
    /**
     从内存池或者是coredata中载入数据
     
     - parameter clubID: 俱乐部id
     
     - returns: 返回club对象
     */
    func getOrLoad(clubID: String) -> Club? {
        if let club = self.clubs[clubID] {
            return club
        }
        let club = context.clubs.first { $0.clubID == clubID }
        return club
    }
    
}