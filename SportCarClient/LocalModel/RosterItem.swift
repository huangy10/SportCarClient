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
    case user(User)
    case club(Club)
}


class RosterItem: BaseModel {
    
    // Insert code here to add functionality to your managed object subclass
    var dataLoaded: Bool = false
    var data:  RosterItemType! {
        didSet {
            // setup the index properties
            switch data! {
            case .user(let chater):
                relatedID = chater.ssid
                entityType = "user"
            case .club(let club):
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
        if let entityType = entityType , entityType == "user", let entityData = entityData {
            let jsonData = JSON(data: entityData)
            let userID = jsonData[User.idField].int32Value
            if let user = ChatModelManger.sharedManager.objectWithSSID(userID) as? User {
                self.data = RosterItemType.user(user)
            } else {
                let user = try! ChatModelManger.sharedManager.getOrCreate(jsonData) as User
                self.data = RosterItemType.user(user)
            }
//            let chater = try! Chater().loadDataFromJSON(jsonData)
//            self.data = RosterItemType.USER(chater)
        } else if let entityType = entityType , entityType == "club", let entityData = entityData {
            let json = JSON(data: entityData)
            let clubID = json[Club.idField].int32Value
            if let club = ChatModelManger.sharedManager.objectWithSSID(clubID)
                as? Club {
                self.data = RosterItemType.club(club)
            } else {
                let club = try! ChatModelManger.sharedManager.getOrCreate(json) as Club
                self.data = RosterItemType.club(club)
            }
            
        } else {
            assertionFailure()
        }
        dataLoaded = true
        
        let _ = RosterItem.alwaysOnTop.___name
    }
    
    func takeChatRecord(_ chat: ChatRecord) -> Bool {
//        print(chat.chatType, self.entityType)
//        print(chat.targetID, self.relatedID)
//        print(chat.senderUser?.ssid)
        return (chat.chatType! == self.entityType && chat.targetID == self.relatedID) || (chat.chatType! == "user" && chat.senderUser!.ssid == self.relatedID)
    }
    
    @discardableResult
    override func loadDataFromJSON(_ data: JSON, detailLevel: Int = 0, forceMainThread: Bool = false) throws -> Self {
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
            let user = try manager.getOrCreate(data["user"]) as User  // level user.chat as nil
            self.data = RosterItemType.user(user)
        } else if entityType == "club" {
            entityData = try! data["club"].rawData()
            let club = try self.manager.getOrCreate(data["club"]) as Club
            club.attended = true
            self.data = RosterItemType.club(club)
            
        } else {
            assertionFailure()
        }
        updatedAt = Date()
        return self
    }
}
