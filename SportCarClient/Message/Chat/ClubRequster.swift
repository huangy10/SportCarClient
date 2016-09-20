//
//  ClubRequster.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlecrimCoreData


class ClubRequester: BasicRequester {
    
    // MARK: overrides
    
    static let sharedInstance = ClubRequester()
    
    fileprivate let _urpMap: [String: String] = [
        "info": "<clubID>/info",
        "discover": "discover",
        "create": "create",
        "list": "list",
        "auth": "<clubID>/auth",
        "update": "<clubID>/update",
        "update_members": "<clubID>/members",
        "quit": "<clubID>/quit",
        "apply": "<clubID>/apply",
        "operation": "<clubID>/operation",
        "billboard": "billboard",
        "cities": "cities"
    ]
    
    override var urlMap: [String : String] {
        return _urpMap
    }
    
    override var namespace: String {
        return "club"
    }
    
    var privateQueue: DispatchQueue {
        return ChatModelManger.sharedManager.workQueue
    }
    
    // MARK: - requests
    
    func getClubInfo(_ clubID: String, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return get(
            urlForName("info", param: ["clubID": clubID]),
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError)
    }
    
    func discoverClub(_ queryType: String, cityLimit: String, extraParam: [String: AnyObject]? = nil, skip: Int, limit: Int, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        var param: [String: AnyObject] = extraParam ?? [:]
        param["query_type"] = queryType
        param["skip"] = skip
        param["limit"] = limit
        param["city_limit"] = cityLimit
        return get(
            urlForName("discover"),
            responseDataField: "data",
            parameters: param,
            onSuccess: onSuccess, onError: onError)
    }
    
    func createNewClub(_ clubName: String, clubLogo: UIImage, members: [String], description: String, onSuccess: (JSON?)->(), onProgress: (_ progress: Float)->(), onError: (_ code: String?)->()) {
        let param: [String: AnyObject] = [
            "name": clubName as AnyObject,
            "logo": clubLogo,
            "members": members as AnyObject,
            "description": description as AnyObject
        ]
        upload(
            urlForName("create"),
            parameters: param,
            responseDataField: "club",
            onSuccess: onSuccess, onProgress: onProgress, onError: onError
        )
    }
    
    func getClubList(_ onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return get(
            urlForName("list"),
            responseDataField: "clubs",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func clubAuth(_ clubID: String, district: String, description: String, onSuccess: (JSON?)->(), onProgress: (_ progress: Float)->(), onError: (_ code: String?)->()) -> Request {
        return post(
            urlForName("auth", param: ["clubID": clubID]),
            parameters: ["city": district, "description": description],
            onSuccess: onSuccess, onProgress: onProgress, onError: onError
        )
    }
    
    // update club settings
    func updateClubSettings(
        _ club: Club,
        onSuccess: (JSON?)->(), onError: (_ code: String?)->()
        ) -> Request {
        let params: [String: AnyObject] = [
            "only_host_can_invite": club.onlyHostCanInvite,
            "show_members_to_public": club.showMembers,
            "nick_name": club.remarkName ?? MainManager.sharedManager.hostUser!.nickName!,
            "show_nick_name": club.showNickName,
            "no_disturbing": club.noDisturbing,
            "always_on_top": club.alwayOnTop,
            "name": club.name!,
            "description": club.clubDescription!
        ]
        return post(
            urlForName("update", param: ["clubID": club.ssidString]),
            parameters: params,
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func updateClubLogo(_ club: Club, newLogo: UIImage, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) {
        upload(
            urlForName("update", param: ["clubID": club.ssidString]),
            parameters: ["logo": newLogo],
            onSuccess: onSuccess, onError: onError
        )
    }
    
    // update club memebers
    func updateClubMembers(_ clubID: String, members: [String], opType: String, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return post(
            urlForName("update_members", param: ["clubID": clubID]),
            encoding: .json,
            parameters: ["op_type": opType, "target_users": members],
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getClubMembers(_ clubID: String, skip: Int, limit: Int, searchText: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return get(
            urlForName("update_members", param: ["clubID": clubID]),
            parameters: ["limit": limit, "skip": skip, "filter": searchText],
            responseDataField: "members", onSuccess: onSuccess, onError: onError
        )
    }
    
    // club quit
    func clubQuit(_ clubID: String, newHostID: String, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request{
        return post(
            urlForName("quit", param: ["clubID": clubID]),
            parameters: ["new_host": newHostID], encoding: .json,
            responseQueue: self.privateQueue,
            onSuccess: onSuccess, onError: onError)
    }
    
    func getClubListAuthed(_ onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        
        return get(
            urlForName("list"),
            parameters: ["authed": "y"],
            responseDataField: "clubs",
            onSuccess: onSuccess, onError: onError)
    }
    
    func applyForAClub(_ clubID: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(
            urlForName("apply", param: ["clubID": clubID]),
            onSuccess: onSuccess, onError: onError)
    }
    
    func clubOperation(
        _ clubID: String,
        targetUserID: String,
        opType: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) -> Request {
        return post(
            urlForName("operation", param: ["clubID": clubID]),
            parameters: ["op_type": opType, "target_user": targetUserID],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func clubBillboard(
        _ skip: Int,
        limit: Int,
        scope: String,
        filterType: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) -> Request {
        return get(urlForName("billboard"), parameters: [
            "skip": skip,
            "limit": limit,
            "scope": scope,
            "filter": filterType
            ], responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func clubPopularCities(_ onSuccess: SSSuccessCallback,
                           onError: SSFailureCallback) -> Request {
        return get(urlForName("cities"), responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
}

