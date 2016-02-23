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

/// 这个类负责构造访问需要的URL
class AccountURLMaker {
    let user: User?
    let website: String
    init(user: User?) {
        self.user = user
        self.website = "\(kProtocalName)://\(kHostName):\(kPortName)"
    }
    
    /**
     请求验证码
     
     - returns: 访问需要的URL
     */
    func requestForCode() -> NSURL? {
        return NSURL(string: website + "/account/sendcode")
    }
    
    /**
     注册
     
     - returns: 访问需要的URL
     */
    func register() -> NSURL?{
        return NSURL(string: website + "/account/register")
    }
    
    func login() -> NSURL? {
        return NSURL(string: website + "/account/login")
    }
    
    func setProfile() -> NSURL? {
        return NSURL(string: website + "/account/profile")
    }
    
    func getProfile(userID: String) -> NSURL? {
        return NSURL(string: website + "/profile/\(userID)/info")
    }
    
    func getFansList(userID: String) -> String{
        return website + "/profile/\(userID)/fans"
    }
    
    func getFollowList(userID: String) -> String {
        return website + "/profile/\(userID)/follows"
    }
}

/// 这个类负责整个注册登陆部分的网络访问请求
class AccountRequester {
    var urlMaker = AccountURLMaker(user: nil)
    let manager: Alamofire.Manager
    
    static let sharedRequester = AccountRequester()
    
    // 下面是一些待提交的数据
    
    init() {
        let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
        let cooks = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        cfg.HTTPCookieStorage = cooks
        cfg.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        self.manager = Alamofire.Manager(configuration: cfg)
    }
    
    /**
     请求发送验证码
     
     - parameter phoneNum:  输入的电话好吗
     - parameter onSuccess: 成功之后调用的closure
     - parameter onError:   出错之后调用的closure
     */
    func requestAuthCode(phoneNum: String, onSuccess: ()->(Void), onError: ()->(Void)){
        manager.request(.POST, urlMaker.requestForCode()!.absoluteString, parameters: ["phone_num": phoneNum]).responseJSON { (response) -> Void in
            
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                if json["success"].boolValue{
                    dispatch_async(dispatch_get_main_queue(), onSuccess)
                }else{
                    dispatch_async(dispatch_get_main_queue(), onError)
                }
                break
            case .Failure(let error):
                print("\(error)")
                dispatch_async(dispatch_get_main_queue(), onError)
                break
            }
        }
    }
    
    func postToLogin(phoneNum: String, password: String, onSuccess: (userID: String?)->(Void), onError: (code: String?)->(Void)) {
        manager.request(.POST, urlMaker.login()!.absoluteString, parameters: ["username": phoneNum, "password": password]).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                if json["success"].boolValue {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let userID = json["userID"].stringValue
                        onSuccess(userID: userID)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                        onError(code: json["code"].string)
                    })
                }
                break
            case .Failure(let error):
                print("\(error)")
                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                    onError(code: "0000")
                })
                break
            }
        }
    }
    
    func postToRegister(phoneNum: String, passwd: String, authCode: String, onSuccess: (userID: String?)->(Void), onError: (code: String?)->(Void)) {
        manager.request(.POST, urlMaker.register()!.absoluteString, parameters: ["username": phoneNum, "password1": passwd, "password2": passwd, "auth_code": authCode]).responseJSON { (response) -> Void in
            
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                if json["success"].boolValue {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let userID = json["userID"].stringValue
                        onSuccess(userID: userID)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        onError(code: json["code"].string)
                    })
                }
                break
            case .Failure(let error):
                print(error)
                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                    onError(code: "0000")
                })
                break
            }
//            
//            guard response.result.isSuccess else{
//                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
//                    onError(code: "0000")
//                })
//                return
//            }
//            let result = response.result.value
//            if result?["success"] as! Bool {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    let userID = result?["userID"] as? Int
//                    onSuccess(userID: userID)
//                })
//            }else {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    onError(code: result?["code"] as? String)
//                })
//            }
        }
    }
    
    func postToSetProfile(nickName: String, gender: String, birthDate: String, avatar: UIImage, onSuccess: ()->(), onError: (code: String?) -> ()) {
        let urlStr = self.urlMaker.setProfile()!.absoluteString
        // 这里将gender数据映射成字母的m和f
        guard let genderLetter = ["男": "m", "女": "f"][gender] else{
            assertionFailure()
            return
        }
        manager.upload(.POST, urlStr, multipartFormData: { (multipartFormData) -> Void in
//            multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(avatar)!, name: "avatar")
            multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(avatar)!, name: "avatar", fileName: "avatar.png", mimeType: "image/png")
            multipartFormData.appendBodyPart(data: nickName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "nick_name")
            multipartFormData.appendBodyPart(data: genderLetter.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "gender")
            multipartFormData.appendBodyPart(data: birthDate.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "birth_date")
            }) { (result) -> Void in
                switch result{
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        switch response.result {
                        case .Success(let value):
                            let json = JSON(value)
                            if json["success"].boolValue {
                                dispatch_async(dispatch_get_main_queue(), onSuccess)
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    onError(code: json["code"].string)
                                })
                            }
                            break
                        case .Failure(let error):
                            print("\(error)")
                            dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                                onError(code: "0000")
                            })

                            break
                        }
//                        guard response.result.isSuccess else {
//                            dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
//                                onError(code: "0000")
//                            })
//                            return
//                        }
//                        let result = response.result.value
//                        if result?["success"] as! Bool {
//                            dispatch_async(dispatch_get_main_queue(), onSuccess)
//                        }else{
//                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                onError(code: result?["code"] as? String)
//                            })
//                        }

                    })
                    break
                case .Failure(let error):
                    print("\(error)")
                    dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                        onError(code: "0000")
                    })
                    break
                }
        }
    }
}

// MARK: - Profile Information
extension AccountRequester {
    
    func resultValueHandler(value: Alamofire.Result<AnyObject, NSError>, dataFieldName: String, onSuccess: (JSON?)->(), onError: (code: String?)->()?) {
        switch value {
        case .Failure(_):
            dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                onError(code: "0000")
            })
            break
        case .Success(let value):
            let json = JSON(value)
            if json["success"].boolValue {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onSuccess(json[dataFieldName])
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                    onError(code: json["code"].string)
                })
            }
            break
        }
    }
    
    func getProfileDataFor(userID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()?) {
        let url = urlMaker.getProfile(userID)?.absoluteString
        manager.request(.GET, url!, parameters: nil).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "user_profile", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取给定id的用户的粉丝列表
     
     - parameter userID:        给定的用户id
     - parameter dateThreshold: 时间分割阈值
     - parameter op_type:       操作类型，只可以取值为more或者latest
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getFansList(userID: String, dateThreshold: NSDate, op_type: String, limit: Int = 20, filterStr: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = urlMaker.getFansList(userID)
        manager.request(.GET
            , urlStr, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""])
            .responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "fans", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取给定id的用户的关注列表
     
     - parameter userID:        给定用户的id
     - parameter dateThreshold: 时间分割阈值
     - parameter op_type:       操作类型，只可以取值为more或者latest
     - parameter limit:         每次获取的最大用户数量
     - parameter filterStr:     搜索参数
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getFollowList(userID: String, dateThreshold: NSDate, op_type: String, limit: Int = 20, filterStr: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = urlMaker.getFollowList(userID)
        manager.request(.GET
            , urlStr, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": op_type, "limit": limit, "filter": filterStr ?? ""])
            .responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "follow", onSuccess: onSuccess, onError: onError)
        }
    }
}
