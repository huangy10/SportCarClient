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


class Activity: NSManagedObject {

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
        maxAttend = location["max_attend"].int32Value
        name = location["name"].string
        poster = location["poster"].string
    }
    
}

class ActivityManager {
    
}
