//
//  AccountRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Dollar

class AccountRequester2: BasicRequester {
    
    static let sharedInstance = AccountRequester2()
    
    fileprivate let _urlMap: [String: String] = [
        "sendcode": "sendcode",
        "login": "login",
        "register": "register",
        "logout": "logout",
        "setprofile": "profile",
        "getprofile": "<userID>/info",
        "get_fans": "<userID>/fans",
        "get_follows": "<userID>/follows",
        "blacklist": "blacklist/update",
        "authed_cars": "<userID>/authed_cars",
        "settings": "settings",
        "corporation_auth": "auth/corporation",
        "modify": "modify",
        "get_blacklist": "blacklist",
        "operation": "<userID>/operation",
        "status": "<userID>/status",
        "permission": "permission",
        "reset": "reset"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "account"
    }
    
    
    // MARK: Orignial Request from old AccountRequester

    func requestAuthCode(_ phoneNum: String, onSuccess: @escaping ()->(Void), onError: @escaping ()->(Void)) -> Request{
        let onFailure: SSFailureCallback = { (code: String?) in
            onError()
        }
        let onSuccessWrapped: SSSuccessCallback = { (json: JSON?) in
            onSuccess()
        }
        return post(
            urlForName("sendcode"),
            parameters: ["phone_num": phoneNum],
            onSuccess: onSuccessWrapped, onError: onFailure)
    }
    
    func postToLogin(
        _ phoneNum: String, password: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback
        ) -> Request {
        var param = ["username": phoneNum, "password": password]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("login"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func postToRegister(_ phoneNum: String, passwd: String, authCode: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        var param = ["username": phoneNum, "password": passwd, "password2": passwd, "auth_code": authCode]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("register"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func logout(_ onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(urlForName("logout"), onSuccess: onSuccess, onError: onError)
    }
    
    func postToSetProfile(
        _ nickName: String,
        gender: String,
        birthDate: String,
        avatar: UIImage,
        onSuccess: @escaping SSSuccessCallback,
        onProgress: @escaping SSProgressCallback,
        onError: @escaping SSFailureCallback) {
        guard let genderLetter = ["男": "m", "女": "f"][gender] else{
            assertionFailure()
            return
        }
        var params: [String: Any] = [:]
        params["avatar"] = avatar
        params["nick_name"] = nickName
        params["gender"] = genderLetter
        params["birth_date"] = birthDate
        upload(urlForName("setprofile"), parameters: params, onSuccess: onSuccess, onProgress: onProgress, onError: onError)
    }
    
    func getProfileDataFor(_ userID: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return get(urlForName("getprofile", param: ["userID": userID]), responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func getFansList(
        _ userID: String,
        dateThreshold: Date,
        op_type: String,
        limit: Int = 20,
        filterStr: String? = nil,
        onSuccess: @escaping SSSuccessCallback,
        onError: @escaping SSFailureCallback
        ) -> Request {
        return get(
            urlForName("get_fans", param: ["userID": userID]), parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getFollowList(
        _ userID: String,
        dateThreshold: Date,
        op_type: String,
        limit: Int = 20,
        filterStr: String? = nil,
        onSuccess: @escaping SSSuccessCallback,
        onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("get_follows", param: ["userID": userID]), parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func block(_ user: User, flag: Bool, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(
            urlForName("operation", param: ["userID": user.ssidString]),
            parameters: ["op_type": "blacklist", "block": flag],
            responseDataField: "blacklist",
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
//    @available(*, deprecated=1)
//    func blacklistUser(user: User, blacklist: Bool, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
//        let request = NSMutableURLRequest(URL: NSURL(string: urlForName("blacklist"))!)
//        request.HTTPMethod = "POST"
//        let params = ["op_type": blacklist ? "add" : "remove", "users": [user.ssidString]] as JSON
//        request.HTTPBody = try! params.rawData()
//        return post(request, onSuccess: onSuccess, onError: onError)
//    }
//    
//    @available(*, deprecated=1)
//    func unblacklistUsers(users: [User], onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
//        let urlStr = urlForName("blacklist")
//        let userIDs = users.map({ $0.ssidString })
//        let request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
//        request.HTTPMethod = "POST"
//        let params = ["op_type":"remove", "users": userIDs] as JSON
//        request.HTTPBody = try! params.rawData()
//        return post(request, onSuccess: onSuccess, onError: onError)
//    }
    
    // MARK: Request from old SportCarRequester
    
    func getAuthedCarsList(_ userID: String, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(urlForName("authed_cars", param: ["userID": userID]),
            responseDataField: "cars", onSuccess: onSuccess, onError: onError
        )
    }
    
    // MARK: Request from old PersonRequester
    
    @available(*, deprecated: 1)
    func getBlackList(
        _ dateThreshold: Date,
        limit: Int,
        onSuccess: @escaping (JSON?)->(),
        onError: @escaping (_ code: String?)->()
        ) -> Request {
        return get(urlForName("get_blacklist"),
                   parameters: ["date_threshold": STRDate(dateThreshold), "op_type": "more", "limit": limit],
                   responseDataField: "users",
                   onSuccess: onSuccess, onError: onError)
    }

    func getBlacklist(_ skip: Int, limit: Int, searchText: String="", onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("get_blacklist"),
            parameters: ["skip": skip, "limit": limit, "search_text": searchText],
            responseDataField: "data",
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    /**
     Get settings from server
     */
    
    func postCorporationUserApplication(_ images: [UIImage], onSuccess: @escaping (JSON?)->(), onProgress: @escaping (_ progress: Float)->(), onError: @escaping (_ code: String?)->()) {
        assert(images.count == 3)
        upload(
            urlForName("corporation_auth"),
            parameters: [
                "license_image": images[0],
                "id_car_image": images[1],
                "other_info_image": images[2]
            ],
            onSuccess: onSuccess, onProgress: onProgress, onError: onError
        )
    }
    
    /**
     Modify the profile information of the current user, the available attributes are 'nick_name', 'avatar', 'avatar_club', 'avatar_car', 'signature',
     'job', 'district'
     */
    func profileModifiy(_ param: [String: Any], onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(urlForName("modify"), parameters: param, onSuccess: onSuccess, onError: onError)
    }
    
    func profileModifyUploadAvatar(
        _ avatar: UIImage, onSuccess: @escaping SSSuccessCallback, onProgress: @escaping SSProgressCallback, onError: @escaping SSFailureCallback
        ) {
        upload(
            urlForName("modify"),
            parameters: ["avatar": avatar],
            onSuccess: onSuccess, onProgress: onProgress, onError: onError
        )
    }
    
    func follow(_ userID: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(
            urlForName("operation", param: ["userID": userID]),
            parameters: ["op_type": "follow"],
            responseDataField: "followed",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    // MARK: Request from old StatusRequester
    
    func getStatusListSimplified(_ userID: String, carID: String?, dateThreshold: Date, limit: Int, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        var params: [String: Any] = ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": "more"]
        if let carID = carID {
            params["filter_car"] = carID
        }
        return get(urlForName("status", param: ["userID": userID]),
                   parameters: params,
                   responseDataField: "data",
                   onSuccess: onSuccess, onError: onError)
    }
    
    // MARK: Permission Check
    
    func syncPermission(_ onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("permission"),
            responseDataField: "data",
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    func resetPassword(_ phoneNum: String, passwd: String, authCode: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        var param = ["username": phoneNum, "password": passwd, "password2": passwd, "auth_code": authCode]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("reset"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
}

