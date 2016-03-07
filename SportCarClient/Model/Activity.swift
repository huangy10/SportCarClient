//
//  Activity.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

func activityTimeDes(act: Activity) -> String{
    let start = act.startAt!
    let end = act.endAt!
    var result = start.stringDisplay()!
    if end.isSameDayWith(start){
        result += " - " + dateDisplayHHMM(end)!
    }else{
        result += " - " + end.stringDisplay()!
    }
    return result
}


class Activity: NSManagedObject {
    
    var applicant = [ActivityJoin]()

// Insert code here to add functionality to your managed object subclass
    static let objects = ActivityManager()
    
    func loadValueFromJSON(json: JSON) {
        actDescription = json["description"].string
        createdAt = DateSTR(json["created_at"].string)
        startAt = DateSTR(json["start_at"].string)
        endAt = DateSTR(json["end_at"].string)
        let location = json["location"]
        location_des = location["description"].string
        location_x = location["lon"].doubleValue
        location_y = location["lat"].doubleValue
        maxAttend = json["max_attend"].int32Value
        name = json["name"].string
        poster = json["poster"].string
        if let likeNum = json["like_num"].int32 {
            self.likeNum = likeNum
        }
        if let commentNum = json["comment_num"].int32 {
            self.commentNum = commentNum
        }
        let userJSON = json["user"]
        self.user = User.objects.create(userJSON).value
        let applicants = json["apply_list"].arrayValue
        if applicants.count > 0 {
            applicant.removeAll()
            for x in applicants {
                applicant.append(ActivityJoin(json: x))
            }
        }
    }
    
    /**
     当前用户加入这个活动
     */
    func hostApply() {
        let host = User.objects.hostUser()!
        if self.user?.userID == host.userID {
            // 如果活动本身是当前用户创建的，则不做报名操作
            return
        }
        var index = 0
        for a in self.applicant {
            if a.user.userID == host.userID {
                // 当前用户已经报名了这个活动
                applicant.removeAtIndex(index)
                return
            }
            index += 1
        }
        // 循环完毕到这里意味着当前用户没有报名这个活动
        let join = ActivityJoin(user: host)
        applicant.append(join)
    }
}

class ActivityManager {
    
    /// 没有发送的活动
    var unSentActs: [Activity] = []
    
    let context = User.objects.defaultContext
    
    func getOrCreate(json: JSON) -> Activity{
        let actID = json["actID"].stringValue
        let act = context.activities.firstOrCreated({ $0.activityID == actID })
        act.loadValueFromJSON(json)
        save()
        return act
    }
    
    func save() -> Bool{
        do {
            try context.save()
            return true
        } catch _{
            return false
        }
    }
}

/// 这个类不放在coredata中了
class ActivityJoin {
    var user: User!
    var approved: Bool = true
    var applyAt: NSDate!
    
    let context = Activity.objects.context
    
    init(json: JSON) {
        loadValueFromJSON(json)
    }
    
    convenience init(user: User) {
        self.init(json: JSON([:]))
        self.user = user
        approved = true
        applyAt = NSDate()
    }
    
    func loadValueFromJSON(json: JSON) {
        approved = json["approved"].boolValue
        applyAt = DateSTR(json["like_at"].string)!
        let userJSON = json["user"]
        user = User.objects.create(userJSON)
    }
}
