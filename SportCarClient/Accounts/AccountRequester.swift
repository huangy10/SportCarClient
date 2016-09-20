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

    func requestAuthCode(_ phoneNum: String, onSuccess: ()->(Void), onError: ()->(Void)) -> Request{
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
        _ phoneNum: String, password: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback
        ) -> Request {
        var param = ["username": phoneNum, "password": password]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("login"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func postToRegister(_ phoneNum: String, passwd: String, authCode: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        var param = ["username": phoneNum, "password": passwd, "password2": passwd, "auth_code": authCode]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("register"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func logout(_ onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(urlForName("logout"), onSuccess: onSuccess, onError: onError)
    }
    
    func postToSetProfile(
        _ nickName: String,
        gender: String,
        birthDate: String,
        avatar: UIImage,
        onSuccess: SSSuccessCallback,
        onProgress: SSProgressCallback,
        onError: SSFailureCallback) {
        guard let genderLetter = ["男": "m", "女": "f"][gender] else{
            assertionFailure()
            return
        }
        var params: [String: AnyObject] = [:]
        params["avatar"] = avatar
        params["nick_name"] = nickName as AnyObject?
        params["gender"] = genderLetter as AnyObject?
        params["birth_date"] = birthDate as AnyObject?
        upload(urlForName("setprofile"), parameters: params, onSuccess: onSuccess, onProgress: onProgress, onError: onError)
    }
    
    func getProfileDataFor(_ userID: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return get(urlForName("getprofile", param: ["userID": userID]), responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func getFansList(
        _ userID: String,
        dateThreshold: Date,
        op_type: String,
        limit: Int = 20,
        filterStr: String? = nil,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) -> Request {
        return get(
            urlForName("get_fans", param: ["userID": userID]), responseDataField: "data",
            parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""],
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getFollowList(
        _ userID: String,
        dateThreshold: Date,
        op_type: String,
        limit: Int = 20,
        filterStr: String? = nil,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback) -> Request {
        return get(
            urlForName("get_follows", param: ["userID": userID]), responseDataField: "data",
            parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""],
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func block(_ user: User, flag: Bool, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
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
    
    func getAuthedCarsList(_ userID: String, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return get(urlForName("authed_cars", param: ["userID": userID]),
            responseDataField: "cars", onSuccess: onSuccess, onError: onError
        )
    }
    
    // MARK: Request from old PersonRequester
    
    @available(*, deprecated: 1)
    func getBlackList(
        _ dateThreshold: Date,
        limit: Int,
        onSuccess: (JSON?)->(),
        onError: (_ code: String?)->()
        ) -> Request {
        return get(urlForName("get_blacklist"),
                   parameters: ["date_threshold": STRDate(dateThreshold), "op_type": "more", "limit": limit],
                   responseDataField: "users",
                   onSuccess: onSuccess, onError: onError)
    }

    func getBlacklist(_ skip: Int, limit: Int, searchText: String="", onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
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
    
    func postCorporationUserApplication(_ images: [UIImage], onSuccess: (JSON?)->(), onProgress: (_ progress: Float)->(), onError: (_ code: String?)->()) {
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
    func profileModifiy(_ param: [String: AnyObject], onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return post(urlForName("modify"), parameters: param, onSuccess: onSuccess, onError: onError)
    }
    
    func profileModifyUploadAvatar(
        _ avatar: UIImage, onSuccess: SSSuccessCallback, onProgress: SSProgressCallback, onError: SSFailureCallback
        ) {
        upload(
            urlForName("modify"),
            parameters: ["avatar": avatar],
            onSuccess: onSuccess, onProgress: onProgress, onError: onError
        )
    }
    
    func follow(_ userID: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(
            urlForName("operation", param: ["userID": userID]),
            parameters: ["op_type": "follow"],
            responseDataField: "followed",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    // MARK: Request from old StatusRequester
    
    func getStatusListSimplified(_ userID: String, carID: String?, dateThreshold: Date, limit: Int, onSuccess: (JSON?)->(), onError: (_ code: String?)->()) -> Request {
        var params: [String: AnyObject] = ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": "more"]
        if let carID = carID {
            params["filter_car"] = carID
        }
        return get(urlForName("status", param: ["userID": userID]),
                   parameters: params,
                   responseDataField: "data",
                   onSuccess: onSuccess, onError: onError)
    }
    
    // MARK: Permission Check
    
    func syncPermission(_ onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return get(
            urlForName("permission"),
            responseDataField: "data",
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    func resetPassword(_ phoneNum: String, passwd: String, authCode: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        var param = ["username": phoneNum, "password": passwd, "password2": passwd, "auth_code": authCode]
        if let token = AppManager.sharedAppManager.deviceTokenString {
            param["device_token"] = token
        }
        return post(urlForName("reset"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
}

//
///// 这个类负责构造访问需要的URL
//class AccountURLMaker {
//    let user: User?
//    let website: String
//    init(user: User?) {
//        self.user = user
//        self.website = "\(kProtocalName)://\(kHostName):\(kPortName)"
//    }
//    
//    /**
//     请求验证码
//     
//     - returns: 访问需要的URL
//     */
//    func requestForCode() -> NSURL? {
//        return NSURL(string: website + "/account/sendcode")
//    }
//    
//    /**
//     注册
//     
//     - returns: 访问需要的URL
//     */
//    func register() -> NSURL?{
//        return NSURL(string: website + "/account/register")
//    }
//    
//    func login() -> NSURL? {
//        return NSURL(string: website + "/account/login")
//    }
//    
//    func logout() -> String {
//        return website + "/account/logout"
//    }
//    
//    func setProfile() -> NSURL? {
//        return NSURL(string: website + "/account/profile")
//    }
//    
//    func getProfile(userID: String) -> NSURL? {
//        return NSURL(string: website + "/profile/\(userID)/info")
//    }
//    
//    func getFansList(userID: String) -> String{
//        return website + "/profile/\(userID)/fans"
//    }
//    
//    func getFollowList(userID: String) -> String {
//        return website + "/profile/\(userID)/follows"
//    }
//    
//    func blacklistUpdate() -> String {
//        return website + "/profile/blacklist/update"
//    }
//}
//
///// 这个类负责整个注册登陆部分的网络访问请求
//@available(*, deprecated=1)
//class AccountRequester {
//    var urlMaker = AccountURLMaker(user: nil)
//    let manager: Alamofire.Manager
//
//    static let sharedRequester = AccountRequester()
//    
//    // 下面是一些待提交的数据
//    
//    init() {
//        let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let cooks = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        cfg.HTTPCookieStorage = cooks
//        cfg.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
//        self.manager = Alamofire.Manager(configuration: cfg)
//    }
//    
//    /**
//     请求发送验证码
//     
//     - parameter phoneNum:  输入的电话好吗
//     - parameter onSuccess: 成功之后调用的closure
//     - parameter onError:   出错之后调用的closure
//     */
//    func requestAuthCode(phoneNum: String, onSuccess: ()->(Void), onError: ()->(Void)){
//        manager.request(.POST, urlMaker.requestForCode()!.absoluteString, parameters: ["phone_num": phoneNum]).responseJSON { (response) -> Void in
//            switch response.result {
//            case .Success(let value):
//                let json = JSON(value)
//                if json["success"].boolValue{
//                    dispatch_async(dispatch_get_main_queue(), onSuccess)
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), onError)
//                }
//                break
//            case .Failure(_):
//                dispatch_async(dispatch_get_main_queue(), onError)
//                break
//            }
//        }
//    }
//    
//    func postToLogin(phoneNum: String, password: String, onSuccess: (json: JSON?)->(Void), onError: (code: String?)->(Void)) {
//        var param = ["username": phoneNum, "password": password]
//        if let token = AppManager.sharedAppManager.deviceTokenString {
//            param["device_token"] = token
//        }
//        manager.request(.POST, urlMaker.login()!.absoluteString, parameters: param).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func postToRegister(phoneNum: String, passwd: String, authCode: String, onSuccess: (json: JSON?)->(Void), onError: (code: String?)->(Void)) {
//        var param = ["username": phoneNum, "password1": passwd, "password2": passwd, "auth_code": authCode]
//        if let token = AppManager.sharedAppManager.deviceTokenString {
//            param["device_token"] = token
//        }
//        manager.request(.POST, urlMaker.register()!.absoluteString, parameters: param).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func logout(onSuccess: (json: JSON?)->(Void), onError: (code: String?)->(Void)) {
//        manager.request(.POST, urlMaker.logout()).responseJSON { (response) in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func postToSetProfile(nickName: String, gender: String, birthDate: String, avatar: UIImage, onSuccess: (json: JSON?)->(), onProgress: (progress: Float) -> (), onError: (code: String?) -> ()) {
//        let urlStr = self.urlMaker.setProfile()!.absoluteString
//        // 这里将gender数据映射成字母的m和f
//        guard let genderLetter = ["男": "m", "女": "f"][gender] else{
//            assertionFailure()
//            return
//        }
//        manager.upload(.POST, urlStr, multipartFormData: { (multipartFormData) -> Void in
//            multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(avatar)!, name: "avatar", fileName: "avatar.png", mimeType: "image/png")
//            multipartFormData.appendBodyPart(data: nickName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "nick_name")
//            multipartFormData.appendBodyPart(data: genderLetter.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "gender")
//            multipartFormData.appendBodyPart(data: birthDate.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "birth_date")
//            }) { (result) -> Void in
//                switch result{
//                case .Success(let upload, _, _):
//                    upload.progress({ (_, written, total) -> Void in
//                        let progress = Float(written) / Float(total)
//                        onProgress(progress: progress)
//                    })
//                    upload.responseJSON(completionHandler: { (response) -> Void in
//                        switch response.result {
//                        case .Success(let value):
//                            let json = JSON(value)
//                            if json["success"].boolValue {
//                                dispatch_async(dispatch_get_main_queue(), { onSuccess(json: json["data"]) })
//                            }else{
//                                dispatch_async(dispatch_get_main_queue(), { onError(code: json["code"].string) })
//                            }
//                            break
//                        case .Failure(_):
//                            dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
//                                onError(code: "0000")
//                            })
//
//                            break
//                        }
//                    })
//                    break
//                case .Failure(_):
//                    dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
//                        onError(code: "0000")
//                    })
//                    break
//                }
//        }
//    }
//}
//
//// MARK: - Profile Information
//extension AccountRequester {
//    
//    func resultValueHandler(value: Alamofire.Result<AnyObject, NSError>, dataFieldName: String, onSuccess: (JSON?)->(), onError: (code: String?)->()?) {
//        switch value {
//        case .Failure(_):
//            onError(code: "0000")
//            break
//        case .Success(let value):
//            let json = JSON(value)
//            if json["success"].boolValue {
//                onSuccess(json[dataFieldName])
//            }else{
//                let code = json["code"].string ?? json["message"].string
//                onError(code: code)
//            }
//            break
//        }
//    }
//    
//    func getProfileDataFor(userID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()?) {
//        let url = urlMaker.getProfile(userID)?.absoluteString
//        manager.request(.GET, url!, parameters: nil).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "user_profile", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取给定id的用户的粉丝列表
//     
//     - parameter userID:        给定的用户id
//     - parameter dateThreshold: 时间分割阈值
//     - parameter op_type:       操作类型，只可以取值为more或者latest
//     - parameter onSuccess:     成功以后调用的closure
//     - parameter onError:       失败以后调用的closure
//     */
//    func getFansList(userID: String, dateThreshold: NSDate, op_type: String, limit: Int = 20, filterStr: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let urlStr = urlMaker.getFansList(userID)
//        manager.request(.GET
//            , urlStr, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""])
//            .responseJSON { (response) -> Void in
//                self.resultValueHandler(response.result, dataFieldName: "fans", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取给定id的用户的关注列表
//     
//     - parameter userID:        给定用户的id
//     - parameter dateThreshold: 时间分割阈值
//     - parameter op_type:       操作类型，只可以取值为more或者latest
//     - parameter limit:         每次获取的最大用户数量
//     - parameter filterStr:     搜索参数
//     - parameter onSuccess:     成功以后调用的closure
//     - parameter onError:       失败以后调用的closure
//     */
//    func getFollowList(userID: String, dateThreshold: NSDate, op_type: String, limit: Int = 20, filterStr: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let urlStr = urlMaker.getFollowList(userID)
//        manager.request(.GET
//            , urlStr, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""])
//            .responseJSON { (response) -> Void in
//                self.resultValueHandler(response.result, dataFieldName: "follow", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func blacklistUser(user: User, blacklist: Bool, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
//        let urlStr = urlMaker.blacklistUpdate()
//        let request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
//        request.HTTPMethod = "POST"
//        let params = ["op_type": blacklist ? "add" : "remove", "users": [user.ssidString]] as JSON
//        request.HTTPBody = try! params.rawData()
//        return manager.request(request)
//            .responseJSON(completionHandler: { (response) in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        })
//    }
//    
//    func unblacklistUsers(users: [User], onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
//        let urlStr = urlMaker.blacklistUpdate()
//        let userIDs = users.map({ $0.ssidString })
//        let request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
//        request.HTTPMethod = "POST"
//        let params = ["op_type":"remove", "users": userIDs] as JSON
//        request.HTTPBody = try! params.rawData()
//        return manager.request(request).responseJSON(completionHandler: { (response) in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        })
//    }
//    
//    
//}
