//
//  ActivityRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import Alamofire


class ActivityRequester: BasicRequester {
    
    static let sharedInstance = ActivityRequester()
    
    private let _urlMap: [String: String] = [
        "operation": "<actID>/operation",
        "close": "<actID>/close",
        "apply": "<actID>/apply",
        "new": "create",
        "comments": "<actID>/comments",
        "new_comment": "<actID>/post_comment",
        "detail": "<actID>",
        "applied": "applied",
        "nearby": "discover",
        "mine": "mine",
        "edit": "<actID>/edit"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "activity"
    }
    
    func getMineActivityList(dateThreshold: NSDate, op_type: String, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(
            urlForName("mine"),
            parameters: ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": op_type],
            responseDataField: "acts",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getNearByActivities(userLocation: CLLocationCoordinate2D, queryDistance: Double, cityLimit: String, skip: Int, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        let lat: Double = userLocation.latitude
        let lon: Double = userLocation.longitude
        return get(
            urlForName("nearby"),
            parameters: ["lon": lon, "lat": lat, "query_distance": queryDistance, "limit": limit, "skip": skip, "city_limit": cityLimit],
            responseDataField: "acts",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getActivityApplied(dateThreshold: NSDate, op_type: String, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(
            urlForName("applied"),
            parameters: ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": op_type],
            responseDataField: "acts",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getActivityDetail(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(
            urlForName("detail", param: ["actID": actID]),
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func sendActivityComment(actID: String, content: String, responseTo: String?, informOf: [String]?,  onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        var param: [String: AnyObject] = [
            "content": content
        ]
        if let responseTo = responseTo {
            param["response_to"] = responseTo
        }
        if let informOf = informOf {
            param["inform_of"] = informOf
        }
        upload(
            urlForName("new_comment", param: ["actID": actID]),
            parameters: param, responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getActivityComments(actID: String, dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(
            urlForName("comments", param: ["actID": actID]),
            parameters: ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": "more"],
            responseDataField: "comments",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func createNewActivity(
        name: String,
        des: String,
        informUser: [String]?,
        maxAttend: Int,
        startAt: NSDate, endAt: NSDate,
        authedUserOnly: Bool,
        poster: UIImage,
        lat: Double, lon: Double, loc_des: String, city: String,
        onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()
        ) {
        var param: [String: AnyObject] = [
            "name": name,
            "description": des,
            "max_attend": maxAttend,
            "start_at": STRDate(startAt),
            "end_at": STRDate(endAt),
            "poster": poster,
            "location": ["lat": lat, "lon": lon, "description": loc_des, "city": city],
            "authed_user_only": authedUserOnly
        ]
        if let informUser = informUser {
            param["inform_of"] = informUser
        }
        upload(urlForName("new"), parameters: param,
               responseDataField: "id",
               onSuccess: onSuccess, onError: onError)
    }
    
    func activityEdit(
        actID: String,
        name: String,
        des: String,
        informUser: [String]?,
        maxAttend: Int,
        startAt: NSDate, endAt: NSDate,
        authedUserOnly: Bool,
        poster: UIImage,
        lat: Double, lon: Double, loc_des: String, city: String,
        onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()
        ) {
        var param: [String: AnyObject] = [
            "name": name,
            "description": des,
            "max_attend": maxAttend,
            "start_at": STRDate(startAt),
            "end_at": STRDate(endAt),
            "poster": poster,
            "location": ["lat": lat, "lon": lon, "description": loc_des, "city": city],
            "authed_user_only": authedUserOnly
        ]
        if let informUser = informUser {
            param["inform_of"] = informUser
        }
        upload(
            urlForName("edit", param: ["actID": actID]),
            parameters: param,
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func postToApplyActivty(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return post(
            urlForName("apply", param: ["actID": actID]),
            responseDataField: "join",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func closeActivty(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return post(urlForName("close", param: ["actID": actID]), onSuccess: onSuccess, onError: onError)
    }
    
    func activityOperation(actID: String, targetUserID: String, opType: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
        return post(
            urlForName("operation", param: ["actID": actID]),
            parameters: ["op_type": opType, "target_user": targetUserID],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
}
