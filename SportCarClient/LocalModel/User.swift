//
//  User.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import CoreData
import SwiftyJSON

class User: BaseModel {
    
    override class var idField: String {
        return "ssid"
    }
    
    var avatarURL: URL? {
        if avatar == nil {
            return nil
        }
        return SFURL(avatar!)
    }
    
    fileprivate var _avatarCarModel: SportCar?
    var avatarCarModel: SportCar? {
        get {
            if avatarCar == nil {
                return nil
            }
            if _avatarCarModel == nil {
                let carJSON = JSON(data: avatarCar!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
                _avatarCarModel = try! manager.getOrCreate(carJSON) as SportCar
            }
            return _avatarCarModel
        }
        set {
            _avatarCarModel = newValue
            avatarCar =  try! _avatarCarModel?.toJSONString(0)
        }
    }
    
    fileprivate var _avatarClubModel: Club?
    var avatarClubModel: Club? {
        get {
            if avatarClub == nil {
                return nil
            }
            if _avatarClubModel == nil {
                let clubJSON = JSON(data: avatarClub!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
                _avatarClubModel = try! manager.getOrCreate(clubJSON) as Club
            }
            return _avatarClubModel
        }
        set {
            _avatarClubModel = newValue
            avatarClub = try! _avatarClubModel?.toJSONString(0)
        }
    }
    
//    private var _chater: Chater?
//    
//    @available(*, deprecated=1)
//    func toChatter() -> Chater {
//        if _chater == nil {
//            _chater = try! Chater().loadDataFromJSON([
//                User.idField: ssidString,
//                "nick_name": nickName!,
//                "avatar": avatar!
//                ])
//        }
//        return _chater!
//    }
    
    fileprivate var _rosterItem: RosterItem?
    var rosterItem: RosterItem? {
        if let roster = _rosterItem {
            return roster
        } else if let hostID = self.manager.hostUserID {
            let context = manager.getOperationContext()
            _rosterItem = context.rosterItems.filter({$0.hostSSID == hostID}).filter({$0.entityType == "user"}).filter({$0.relatedID == self.ssid}).first()
            return _rosterItem
        } else {
            return nil
        }
    }
    
    var chatName: String {
        if let noteName = noteName , noteName != "" {
            return noteName
        } else {
            return nickName!
        }
    }
    
    fileprivate var _clubNickName: String?
    var clubNickName: String {
        set {
            _clubNickName = clubNickName
        }
        get {
            if let name = _clubNickName , name != "" {
                return name
            } else {
                return nickName!
            }
        }
    }
     
    @discardableResult
    override func loadDataFromJSON(_ data: JSON, detailLevel: Int, forceMainThread: Bool = false) throws -> Self {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        nickName = data["nick_name"].stringValue
        avatar = data["avatar"].stringValue
        recentStatusDes = data["recent_status"].stringValue
        identified = data["identified"].boolValue
        gender = data["gender"].stringValue
        let noteNameJson = data["note_name"]
        if !noteNameJson.isEmpty {
            noteName = noteNameJson.stringValue
        }
        
        let clubNameJson = data["club_name"]
        if clubNameJson.exists() {
            _clubNickName = clubNameJson.stringValue
        }
        if detailLevel >= 1 {
            district = data["district"].stringValue
            phoneNum = data["phoneNum"].stringValue
            starSign = data["star_sign"].stringValue
            age = data["age"].int32Value
            signature = data["signature"].stringValue
            if let f = data["followed"].bool {
                followed = f
            }
            if let b = data["blacklist"].bool {
                blacklisted = b
            }
            
            fansNum = data["fans_num"].int32Value
            followsNum = data["follow_num"].int32Value
            statusNum = data["status_num"].int32Value
            
            let carJSON = data["avatar_car"]
            if carJSON.exists() {
                avatarCar = carJSON.rawString()
                _avatarCarModel = try manager.getOrCreate(carJSON) as SportCar
            } else {
                avatarCar = nil
                _avatarCarModel = nil
            }
            
            let clubJSON = data["avatar_club"]
            if clubJSON.exists() {
                avatarClub = clubJSON.rawString()
                _avatarClubModel = try manager.getOrCreate(clubJSON) as Club
            } else {
                avatarClub = nil
                _avatarClubModel = nil
            }
        }
        
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        if detailLevel > 0 {
            assertionFailure("Not supported")
        }
        let json = [User.idField: ssidString, "nick_name": nickName!, "avatar": avatar!, "note_name": noteName ?? ""] as JSON
        return json
    }
    // MARK: 一下是User自己的Utility函数
    var isHost: Bool {
        return ssid == MainManager.sharedManager.hostUserID!
    }
    
    class func reorganizeJSON(_ json: JSON) -> JSON {
        var tempJSON = json["user"]
        for (key, value) in json {
            if key == "user" {
                continue
            }
            tempJSON[key] = value
        }
        return tempJSON

    }
}

// MARK: - 导出UI
extension User {
    
    func showDetailController() -> UIViewController {
//        if isHost {
//            return PersonBasicController(user: self)
//        } else {
//            return PersonOtherController(user: self)
//        }
        return PersonController(user: self)
    }
    
}

