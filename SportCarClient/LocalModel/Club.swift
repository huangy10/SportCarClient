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

class Club: BaseModel {
    
    var members: [User] = []
    
    override class var idField: String {
        return "id"
    }
    
    var logoURL: NSURL? {
        if logo == nil {
            return nil
        }
        return SFURL(logo!)
    }
    
    private var _founderUser: User?
    var founderUser: User? {
        if founder == nil {
            return nil
        }
        if _founderUser == nil {
            let founderJSON = JSON(data: founder!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
            _founderUser = try! manager.getOrCreate(founderJSON) as User
        }
        return _founderUser
    }
    
    var recentActivity: Activity? = nil

    override func loadDataFromJSON(var data: JSON, detailLevel: Int = 0, forceMainThread: Bool = false) throws -> Self {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        // TODO: 统一数据的样式
//        if data["club"].isExists() {
//            // Club Joining的样式，重整json的结构
//            var clubJSON = data["club"]
//            for (key, value) in clubJSON {
//                if key == "club" {
//                    continue
//                }
//                clubJSON[key] = value
//            }
//            data = clubJSON
//        }
        data = Club.reorganizeJSON(data)
        name = data["club_name"].stringValue
        if name == "" {
            print(data)
            assertionFailure()
        }
        logo = data["club_logo"].stringValue
        clubDescription = data["description"].stringValue
        identified = data["identified"].boolValue
        city = data["city"].string ?? ""
        let founderJSON = data["host"]
        founder = founderJSON.rawString()
        _founderUser = try! manager.getOrCreate(founderJSON) as User
        mine = _founderUser?.ssid == manager.hostUserID
        let actJSON = data["recent_act"]
        if actJSON.isExists() {
            self.recentActivity = try manager.getOrCreate(actJSON) as Activity
        }
        let attendedJSON = data["attended"]
        if attendedJSON.isExists() {
            attended = attendedJSON.boolValue
        }
        let memberNumJSON = data["members_num"]
        if memberNumJSON.isExists() {
            memberNum = memberNumJSON.int32Value
        }
        let showMembersJSON = data["show_members_to_public"]
        if showMembersJSON.isExists() {
            showMembers = showMembersJSON.boolValue
        }
        let onlyHostInviteJSON = data["only_host_can_invite"]
        if onlyHostInviteJSON.isExists() {
            onlyHostCanInvite = onlyHostInviteJSON.boolValue
        }
        let showNickNameJSON = data["show_nick_name"]
        if showNickNameJSON.isExists() {
            showNickName = showNickNameJSON.boolValue
        }
        let noDisturbingJSON = data["no_disturbing"]
        if noDisturbingJSON.isExists() {
            noDisturbing = noDisturbingJSON.boolValue
        }
        let alwaysOnTopJSON = data["always_on_top"]
        if alwaysOnTopJSON.isExists() {
            alwayOnTop = alwaysOnTopJSON.boolValue
        }
        // TODO: nickname
        // TODO: values
        // TODO: members
        return self
    }
    
    func updateClubSettings(data: JSON) -> Self {
        let showMembersJSON = data["show_members_to_public"]
        if showMembersJSON.isExists() {
            showMembers = showMembersJSON.boolValue
        }
        let onlyHostInviteJSON = data["only_host_can_invite"]
        if onlyHostInviteJSON.isExists() {
            onlyHostCanInvite = onlyHostInviteJSON.boolValue
        }
        let showNickNameJSON = data["show_nick_name"]
        if showNickNameJSON.isExists() {
            showNickName = showNickNameJSON.boolValue
        }
        let noDisturbingJSON = data["no_disturbing"]
        if noDisturbingJSON.isExists() {
            noDisturbing = noDisturbingJSON.boolValue
        }
        let alwaysOnTopJSON = data["always_on_top"]
        if alwaysOnTopJSON.isExists() {
            alwayOnTop = alwaysOnTopJSON.boolValue
        }
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        var json = [
            Club.idField: ssidString,
            "logo": logo!,
            "description": clubDescription!,
            "identified": identified,
            "city": city!,
            "name": name!,
        ] as JSON
        json["host"] = try _founderUser!.toJSONObject(0)
        return json
    }
    
    class func reorganizeJSON(json: JSON) -> JSON{
        var temp = json["club"]
        if temp.isExists() {
            for (key, value) in json {
                if key == "club" {
                    continue
                }
                temp[key] = value
            }
            return temp
        } else {
            return json
        }
    }
}
