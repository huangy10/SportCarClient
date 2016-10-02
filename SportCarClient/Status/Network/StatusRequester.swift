//
//  StatusRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class StatusRequester: BasicRequester {
    
    static let sharedInstance = StatusRequester()
    
    fileprivate let _urlMap: [String: String] = [
        "get": "list",
        "new_status": "post",
        "detail": "<statusID>",
        "comments": "<statusID>/comments",
        "post_comment": "<statusID>/post_comments",
        "operation": "<statusID>/operation"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "status"
    }
    
    func getLatestStatusList(_ dateThreshold: Date, queryType: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(urlForName("get"), parameters: ["date_threshold": STRDate(dateThreshold), "limit": 20, "op_type": "latest", "query_type": queryType],
                   responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func getMoreStatusList(_ dateThreshold: Date, queryType: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(urlForName("get"), parameters: ["date_threshold": STRDate(dateThreshold), "limit": 20, "op_type": "more", "query_type": queryType],
                   responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func getNearByStatus(
        _ dateThreshold: Date,
        opType: String, lat: Double,
        lon: Double, distance: Double,
        onSuccess: @escaping SSSuccessCallback,
        onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("get"),
            parameters: [
                "date_threshold": STRDate(dateThreshold),
                "op_type": opType,
                "limit": 20,
                "lat": lat,
                "lon": lon,
                "distance": distance,
                "query_type": "nearby"
            ],
            responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func postNewStatus(_ content: String, image: UIImage, car_id: String?, lat: Double, lon: Double, loc_description: String, informOf: [String]?,
        onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->(), onProgress: @escaping (_ progress: Float)->()
        ) {
        var param: [String: AnyObject] = [
            "image1": image,
            "content": content as AnyObject,
            "lat": "\(lat)" as AnyObject,
            "lon": "\(lon)" as AnyObject,
            "location_description": loc_description as AnyObject,
            "user_id": MainManager.sharedManager.hostUserIDString! as AnyObject
        ]
        if let car_id = car_id {
            param["car_id"] = car_id as AnyObject?
        }
        if let inform = informOf , inform.count > 0 {
            param["inform_of"] = inform as AnyObject?
        }
        upload(
            urlForName("new_status"),
            parameters: param,
            responseDataField: "data",
            onSuccess: onSuccess,
            onProgress: onProgress,
            onError: onError
        )
    }
    
    func getStatusDetail(_ statusID: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return get(urlForName("detail", param: ["statusID": statusID]), responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func getMoreStatusComment(_ dateThreshold: Date, statusID: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(urlForName("comments", param: ["statusID": statusID]),
                   parameters: ["date_threshold": STRDate(dateThreshold), "limit": 20, "op_type": "more"],
                   responseDataField: "comments", onSuccess: onSuccess, onError: onError)
    }
    
    func postCommentToStatus(_ statusID: String, content: String, responseTo: String?, informOf: [String]?,  onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->())
    {
        var param: [String: AnyObject] = [
            "content": content as AnyObject,
        ]
        if let responseTo = responseTo {
            param["response_to"] = responseTo as AnyObject?
        }
        if let informOf = informOf {
            param["inform_of"] = informOf as AnyObject?
        }
        upload(urlForName("post_comment", param: ["statusID": statusID]),
               parameters: param, responseDataField: "id",
               onSuccess: onSuccess, onError: onError)
    }
    
    func deleteStatus(_ statusID: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(
            urlForName("operation", param: ["statusID": statusID]),
            parameters: ["op_type": "delete"],
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func likeStatus(_ statusID: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(
            urlForName("operation", param: ["statusID": statusID]),
            parameters: ["op_type": "like"],
            responseDataField: "like_info",
            onSuccess: onSuccess, onError: onError
        )
    }
}

