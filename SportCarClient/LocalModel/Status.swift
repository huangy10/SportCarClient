//
//  Status.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


class Status: BaseModel {
    
    override class var idField: String {
        return "statusID"
    }
    
    fileprivate var _location: LocationModel?
    var location: LocationModel? {
        if loc == nil {
            return nil
        } else if _location == nil {
            do {
                _location = try LocationModel().fromJSONString(loc!, detailLevel: 0)
            } catch {
                assertionFailure()
            }
        }
        return _location
    }
    
    var coverURL: URL? {
        if image == nil {
            return nil
        }
        return SFURL(image!)
    }
    
    var thumbnailURL: URL? {
        if thumbnail == nil {
            return nil
        }
        return SFURL(thumbnail!)
    }
    
    fileprivate var _car: SportCar?
    var car: SportCar? {
        if carInfo == nil {
            return nil
        }
        if _car == nil {
            let carJSON = JSON(data: carInfo!.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
            _car = try! manager.getOrCreate(carJSON) as SportCar
        }
        return _car
    }

    override func loadDataFromJSON(_ data: JSON, detailLevel: Int, forceMainThread: Bool) throws -> Self {
        try super.loadDataFromJSON(data, detailLevel: detailLevel, forceMainThread: forceMainThread)
        content = data["content"].stringValue
        createdAt = DateSTR(data["created_at"].stringValue)
        image = data["images"].stringValue.split(";").first()
        loc = data["location"].rawString()
        _location = try LocationModel().loadDataFromJSON(data["location"])
        if let likeNum = data["like_num"].int32 {
            self.likeNum = likeNum
        }
        if let commentNum = data["comment_num"].int32 {
            self.commentNum = commentNum
        }
        if let liked = data["liked"].bool {
            self.liked = liked
        }
        
        let carJSON = data["car"]
        if carJSON.exists() {
            carInfo = carJSON.rawString()
            _car = try manager.getOrCreate(carJSON) as SportCar
            carID = _car!.ssid
        }
        
        let userJSON = data["user"]
        user = try manager.getOrCreate(userJSON) as User
        mine = user?.ssid == manager.hostUserID
        sent = true
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        if detailLevel > 1 {
            throw SSModelError.notSupported
        }
        var json = [
            Status.idField: ssidString,
            "content": content!,
            "images": image! + ";",
            "created_at": STRDate(createdAt!),
        ] as JSON
        json["location"] = try location!.toJSONObject(0)
        json["user"] = try user!.toJSONObject(0)
        return json
    }

}
