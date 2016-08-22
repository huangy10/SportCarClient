//
//  RosterItem.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON

enum RosterItemType {
    case USER(Chater)
    case CLUB(Club)
}


class RosterItem: BaseModel {
    
    // Insert code here to add functionality to your managed object subclass
    var dataLoaded: Bool = false
    var data:  RosterItemType! {
        didSet {
            // setup the index properties
            switch data! {
            case .USER(let chater):
                relatedID = chater.ssid
                entityType = "user"
            case .CLUB(let club):
                relatedID = club.ssid
                entityType = "club"
            }
        }
    }
    
    var mapKey: String {
        return "\(self.entityType!):\(self.relatedID)"
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        loadData()
    }
    
    func loadData() {
        if dataLoaded {
            return
        }
        if let entityType = entityType where entityType == "user", let entityData = entityData {
            let jsonData = JSON(data: entityData)
            let chater = try! Chater().loadDataFromJSON(jsonData)
            self.data = RosterItemType.USER(chater)
        } else if let entityType = entityType where entityType == "club", let entityData = entityData {
            let json = JSON(data: entityData)
            let clubID = json[Club.idField].int32Value
            if let club = ChatModelManger.sharedManager.objectWithSSID(clubID)
                as? Club {
                self.data = RosterItemType.CLUB(club)
            } else {
                let club = try! ChatModelManger.sharedManager.getOrCreate(json) as Club
                self.data = RosterItemType.CLUB(club)
            }
            
        } else {
            assertionFailure()
        }
        dataLoaded = true
    }
    
    func takeChatRecord(chat: ChatRecord) -> Bool {
        return chat.chatType! == self.entityType && chat.targetID == self.relatedID
    }
    
    override func loadDataFromJSON(data: JSON, detailLevel: Int = 0, forceMainThread: Bool = false) throws -> Self {
        try super.loadDataFromJSON(data, detailLevel: detailLevel)
        let entityType = data["entity_type"].stringValue
        self.recentChatDes = data["recent_chat"].stringValue
        self.unreadNum = data["unread_num"].int32Value
        self.alwaysOnTop = data["always_on_top"].boolValue
        self.noDisturbing = data["no_disturbing"].boolValue
        self.updatedAt = DateSTR(data["updated_at"].stringValue)
        self.createdAt = DateSTR(data["created_at"].stringValue)
        if entityType == "user" {
            self.entityData = try! data["user"].rawData()
            let user = try Chater().loadDataFromJSON(data["user"])  // level user.chat as nil
            self.data = RosterItemType.USER(user)
        } else if entityType == "club" {
            entityData = try! data["club"].rawData()
            let club = try self.manager.getOrCreate(data["club"]) as Club
            club.attended = true
            self.data = RosterItemType.CLUB(club)
            
        } else {
            assertionFailure()
        }
        updatedAt = NSDate()
        return self
    }
}
