//
//  Activity.swift
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


class Activity: BaseModel {
    
    
    override class var idField: String {
        return "actID"
    }
    
    var applicants: [User] = []
    
    private var _location: LocationModel?
    var location: LocationModel? {
        if loc == nil {
            return nil
        } else if _location == nil {
            do {
                _location = try LocationModel().fromJSONString(loc!, detailLevel: 0)
            } catch (let err) {
                print(err)
                assertionFailure()
            }
        }
        return _location
    }
    
    var posterURL: NSURL? {
        if poster == nil {
            return nil
        }
        return SFURL(poster!)
    }
    
    var timeDes: String? {
        if startAt == nil || endAt == nil {
            return nil
        }
        var result = startAt!.stringDisplay()!
        if endAt!.isSameDayWith(startAt!){
            result += " - " + dateDisplayHHMM(endAt!)!
        }else{
            result += " - " + endAt!.stringDisplay()!
        }
        return result
    }
    
    var finished: Bool {
        return endAt!.compare(NSDate()) == .OrderedAscending
    }

    override func loadDataFromJSON(data: JSON, detailLevel: Int = 0, forceMainThread: Bool = false) throws -> Activity {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        actDescription = data["description"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        startAt = DateSTR(data["start_at"].stringValue)
        endAt = DateSTR(data["end_at"].stringValue)
        loc = data["location"].rawString()
        _location = try LocationModel().fromJSONString(loc!, detailLevel: 0)
        maxAttend = data["max_attend"].int32Value
        name = data["name"].stringValue
        poster = data["poster"].stringValue
        liked = data["liked"].boolValue
        if data["applied"].exists() {
            applied = data["applied"].boolValue
        }
        if let liked = data["liked"].bool {
            self.liked = liked
        }
        if let likeNum = data["like_num"].int32 {
            self.likeNum = likeNum
        }
        if let commentNum = data["comment_num"].int32 {
            self.commentNum = commentNum
        }
        let userJSON = data["user"]
        user = try manager.getOrCreate(userJSON) as User
        mine =  user?.ssid == manager.hostUserID
        if detailLevel >= 1 {
            let applicantsJSON = data["apply_list"].arrayValue
            if applicantsJSON.count > 0 {
                applicants.removeAll()
                for applicant in applicantsJSON {
                    applicants.append(try manager.getOrCreate(User.reorganizeJSON(applicant)))
                }
            }
        }
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        var json = [
            Activity.idField: ssidString,
            "description": actDescription!,
            "created_at": STRDate(createdAt!),
            "startAt": STRDate(startAt!),
            "endAt": STRDate(endAt!),
            "max_attend": "\(maxAttend)",
            "poster": poster!,
            "name": name!,
            "liked": liked
        ] as JSON
        json["location"] = try! _location!.toJSONObject(0)
        json["user"] = try! user!.toJSONObject(0)
        return json
    }
    
    func hostApply() -> Self {
        if mine {
            return self
        }
        if $.find(applicants, callback: {return $0.ssid == self.manager.hostUserID!}) != nil {
            // 发现已经报名了
            applicants = $.remove(applicants, callback: {return $0.ssid == self.manager.hostUserID!})
            applied = false
        } else {
            // 否则报名
            applicants.append(manager.hostUser!)
            applied = true
        }
        return self
    }
    
    func removeApplicant(user: User) -> Self {
        applicants = $.remove(applicants, callback: {return $0.ssid == user.ssid})
        return self
    }
}
