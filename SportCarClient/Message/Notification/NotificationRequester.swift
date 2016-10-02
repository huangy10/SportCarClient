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
    
    fileprivate let _urlMap: [String: String]  = [
        "get": "list",
        "mark_read": "<notifID>",
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "notification"
    }
    
    var privateQueue: DispatchQueue {
        return ChatModelManger.sharedManager.workQueue
    }
    
    func getNotifications(_ skips: Int, limit: Int = 20, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request{
        
        let params: [String : Any] = [
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
    
    func notifMarkRead(_ notifID:String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(
            urlForName("mark_read", param: ["notifID": notifID]),
            onSuccess: onSuccess, onError: onError)
    }
}



