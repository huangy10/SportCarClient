//
//  Club.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData
import Dollar

class Club: BaseModel {
    
    var members: [User] = []
    
    override class var idField: String {
        return "id"
    }
    
    var logoURL: URL? {
        if logo == nil {
            return nil
        }
        return SFURL(logo!)
    }
    
    fileprivate var _founderUser: User?
    var founderUser: User? {
        if founder == nil {
            return nil
        }
        if _founderUser == nil {
            let founderJSON = JSON(data: founder!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            _founderUser = try! manager.getOrCreate(founderJSON) as User
        }
        return _founderUser
    }
    
    fileprivate var _rosterItem: RosterItem?
    var rosterItem: RosterItem? {
        get {
            if let roster = _rosterItem {
                return roster
            } else if let hostID = self.manager.hostUserID {
                let context = manager.getOperationContext()
                _rosterItem = context.rosterItems
                    .filter({ $0.hostSSID == hostID })
                    .filter({ $0.relatedID == self.ssid })
                    .filter({ $0.entityType == "club"})
                    .first()
                _rosterItem?.loadData()
                return _rosterItem
            } else {
                return nil
            }
        }
        set {
            _rosterItem = newValue
        }
    }
    
    @available(*, deprecated: 1)
    var recentActivity: Activity? = nil

    override func loadDataFromJSON(_ data: JSON, detailLevel: Int = 0, forceMainThread: Bool = false) throws -> Self {
        var data = data
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        data = Club.reorganizeJSON(data)
        name = data["club_name"].stringValue
        logo = data["club_logo"].stringValue
        clubDescription = data["description"].stringValue
        identified = data["identified"].boolValue
        city = data["city"].string ?? ""
        let founderJSON = data["host"]
        founder = founderJSON.rawString()
        _founderUser = try! manager.getOrCreate(founderJSON) as User
        mine = _founderUser?.ssid == manager.hostUserID
//        let actJSON = data["recent_act"]
//        if actJSON.exists() {
//            self.recentActivity = try manager.getOrCreate(actJSON) as Activity
//        }
        let attendedJSON = data["attended"]
        if attendedJSON.exists() {
            attended = attendedJSON.boolValue
        }
        let memberNumJSON = data["members_num"]
        if memberNumJSON.exists() {
            memberNum = memberNumJSON.int32Value
        }
        let showMembersJSON = data["show_members_to_public"]
        if showMembersJSON.exists() {
            showMembers = showMembersJSON.boolValue
        }
        let onlyHostInviteJSON = data["only_host_can_invite"]
        if onlyHostInviteJSON.exists() {
            onlyHostCanInvite = onlyHostInviteJSON.boolValue
        }
        let showNickNameJSON = data["show_nick_name"]
        if showNickNameJSON.exists() {
            showNickName = showNickNameJSON.boolValue
        }
        let noDisturbingJSON = data["no_disturbing"]
        if noDisturbingJSON.exists() {
            noDisturbing = noDisturbingJSON.boolValue
        }
        let alwaysOnTopJSON = data["always_on_top"]
        if alwaysOnTopJSON.exists() {
            alwayOnTop = alwaysOnTopJSON.boolValue
        }
        self.value = data["value_total"].int32Value
        return self
    }
    
    func updateClubSettings(_ data: JSON) -> Self {
        let showMembersJSON = data["show_members_to_public"]
        if showMembersJSON.exists() {
            showMembers = showMembersJSON.boolValue
        }
        let onlyHostInviteJSON = data["only_host_can_invite"]
        if onlyHostInviteJSON.exists() {
            onlyHostCanInvite = onlyHostInviteJSON.boolValue
        }
        let showNickNameJSON = data["show_nick_name"]
        if showNickNameJSON.exists() {
            showNickName = showNickNameJSON.boolValue
        }
        let noDisturbingJSON = data["no_disturbing"]
        if noDisturbingJSON.exists() {
            noDisturbing = noDisturbingJSON.boolValue
        }
        let alwaysOnTopJSON = data["always_on_top"]
        if alwaysOnTopJSON.exists() {
            alwayOnTop = alwaysOnTopJSON.boolValue
        }
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        var json = [
            Club.idField: ssidString,
            "club_logo": logo!,
            "description": clubDescription!,
            "identified": identified,
            "city": city!,
            "club_name": name!,
        ] as JSON
        json["host"] = try founderUser!.toJSONObject(0)
        return json
    }
    
    class func reorganizeJSON(_ json: JSON) -> JSON{
        var temp = json["club"]
        if temp.exists() {
            for (key, value) in json {
                if key == "club" || key == Club.idField {
                    continue
                }
                temp[key] = value
            }
            return temp
        } else {
            return json
        }
    }
    
    func addMember(_ user: User) {
        self.members.append(user)
    }
    
    func remove(member user: User) {
        let oldLength = members.count
        members = $.remove(members, callback: { $0.ssid == user.ssid })
        self.memberNum -= oldLength - members.count
    }
}

