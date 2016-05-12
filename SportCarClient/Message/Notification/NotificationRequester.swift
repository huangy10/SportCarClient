//
//  NotificationRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/7.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlecrimCoreData


class NotificationRequester: BasicRequester {
    static let sharedInstance = NotificationRequester()
    
    private let _urlMap: [String: String]  = [
        "get": "list",
        "mark_read": "<notifID>",
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "notification"
    }
    
    var privateQueue: dispatch_queue_t {
        return ChatModelManger.sharedManager.workQueue
    }
    
    func getNotifications(skips: Int, limit: Int = 20, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
        
        let params: [String : AnyObject] = [
            "limit": limit,
            "skips": skips
        ]
        return get(
            urlForName("get"),
            parameters: params,
            responseQueue: privateQueue,
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func notifMarkRead(notifID:String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return post(
            urlForName("mark_read", param: ["notifID": notifID]),
            onSuccess: onSuccess, onError: onError)
    }
}



