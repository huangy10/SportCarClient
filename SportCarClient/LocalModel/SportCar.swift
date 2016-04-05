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
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        image = data["image"].stringValue
        logo = data["logo"].stringValue

        name = data["name"].stringValue
        if detailLevel >= 1 {
            price = data["price"].stringValue
            engine = data["engine"].stringValue
            body = data["body"].stringValue
            maxSpeed = data["speed"].stringValue
            zeroTo60 = data["acce"].stringValue
            torque = data["torque"].stringValue
        }
        identified = data["identified"].boolValue
        signature = data["signature"].stringValue
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
