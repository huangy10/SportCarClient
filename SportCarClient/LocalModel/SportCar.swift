//
//  SportCar.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON

class SportCar: BaseModel{
    
    override class var idField: String {
        return "carID"
    }
    
    var logoURL: NSURL? {
        if logo == nil {
            return nil
        }
        return SFURL(logo!)
    }
    
    var imageURL: NSURL? {
        if image == nil {
            return nil
        }
        return SFURL(image!)
    }

    override func loadDataFromJSON(data: JSON, detailLevel: Int, forceMainThread: Bool) throws -> Self {
        var json = data
        if data["car"].exists() {
            json = SportCar.reorgnaizeJSON(data)
        }
        try super.loadDataFromJSON(json, detailLevel: detailLevel, forceMainThread: forceMainThread)
        image = json["image"].stringValue
        logo = json["logo"].stringValue
        name = json["name"].stringValue
        if detailLevel >= 1 {
            price = json["price"].stringValue
            engine = json["engine"].stringValue
            body = json["body"].stringValue
            maxSpeed = json["speed"].stringValue
            zeroTo60 = json["acce"].stringValue
            torque = json["torque"].stringValue
        }
        identified = json["identified"].boolValue
        signature = json["signature"].string
        return self
    }
    
    override func toJSONObject(detailLevel: Int) throws -> JSON {
        return [
            SportCar.idField: ssidString,
            "image": image!,
            "name": name!,
            "logo": logo!
        ]
    }
    
    class func reorgnaizeJSON(json: JSON) -> JSON {
        var tempJSON = json["car"]
        for (key, value) in json {
            if key == "car" {
                continue
            }
            tempJSON[key] = value
        }
        return tempJSON
    }
}
