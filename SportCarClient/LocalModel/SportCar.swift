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
import Dollar

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
    
    var imageArray: [NSURL]!
    var videoURL: NSURL?
    var audioURL: NSURL?
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        let imagesRaw = JSON(data: images!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        imageArray = $.map(imagesRaw.arrayValue, transform: { SFURL($0.stringValue)!})
        
        if let video = video {
            videoURL = SFURL(video)
        }
        if let audio = audio {
            audioURL = SFURL(audio)
        }
    }

    override func loadDataFromJSON(data: JSON, detailLevel: Int, forceMainThread: Bool) throws -> Self {
        var json = data
        if data["car"].exists() {
            json = SportCar.reorgnaizeJSON(data)
        }
        try super.loadDataFromJSON(json, detailLevel: detailLevel, forceMainThread: forceMainThread)
        let media = json["medias"]
        let imagesRaw = media["image"]
        images = String(data: try! imagesRaw.rawData(), encoding: NSUTF8StringEncoding)
        imageArray = $.map(imagesRaw.arrayValue, transform: { SFURL($0.stringValue)! })
        let audioRaw = media["audio"].arrayValue
        if audioRaw.count > 0 {
            audio = audioRaw[0].stringValue
            audioURL = SFURL(audio!)
        }
        let videoRaw = media["video"].arrayValue
        if videoRaw.count > 0 {
            video = videoRaw[0].stringValue
            videoURL = SFURL(video!)
            print(video, videoURL)
        }
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
        let json: NSMutableDictionary = [
            SportCar.idField: ssidString,
            "name": name!,
            "logo": logo!,
        ]
        var media = [
            "image": images!
        ]
        if let video = self.video {
            media["video"] = video
        }
        if let audio = self.audio {
            media["audio"] = audio
        }
        json["media"] = media
        return JSON(json)
        
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
