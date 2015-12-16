//
//  AccountRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire

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
            if response.result.isSuccess && response.result.value?["success"] as! Bool{
                // 由于onSuccess里面可能对的UI做出更改，这里需要保证这个closure在主线程上执行，下面的onError同
                dispatch_async(dispatch_get_main_queue(), onSuccess)
            }else{
                dispatch_async(dispatch_get_main_queue(), onError)
            }
        }
    }
    
    func postToLogin(phoneNum: String, password: String, onSuccess: (userID: Int?)->(Void), onError: (code: String?)->(Void)) {
        manager.request(.POST, urlMaker.login()!.absoluteString, parameters: ["username": phoneNum, "password": password]).responseJSON { (response) -> Void in
            if response.result.isFailure {
                // 0000错误代码，一般是由于网络原因或者服务器错误导致的
                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                    onError(code: "0000")
                })
                return
            }
            let result = response.result.value
            if result?["success"] as! Bool {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let userID = result?["userID"] as? Int
                    onSuccess(userID: userID)
                })
            }else{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onError(code: result?["code"] as? String)
                })
            }
        }
    }
    
    func postToRegister(phoneNum: String, passwd: String, authCode: String, onSuccess: (userID: Int?)->(Void), onError: (code: String?)->(Void)) {
        manager.request(.POST, urlMaker.register()!.absoluteString, parameters: ["username": phoneNum, "password1": passwd, "password2": passwd, "auth_code": authCode]).responseJSON { (response) -> Void in
            guard response.result.isSuccess else{
                dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                    onError(code: "0000")
                })
                return
            }
            let result = response.result.value
            if result?["success"] as! Bool {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let userID = result?["userID"] as? Int
                    onSuccess(userID: userID)
                })
            }else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onError(code: result?["code"] as? String)
                })
            }
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
            multipartFormData.appendBodyPart(data: UIImagePNGRepresentation(avatar)!, name: "avatar")
            multipartFormData.appendBodyPart(data: nickName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "nick_name")
            multipartFormData.appendBodyPart(data: genderLetter.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "gender")
            multipartFormData.appendBodyPart(data: birthDate.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "birth_date")
            }) { (result) -> Void in
                switch result{
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        print("\(response.result.value)")
                        guard response.result.isSuccess else {
                            dispatch_async(dispatch_get_main_queue(), { ()->(Void) in
                                onError(code: "0000")
                            })
                            return
                        }
                        let result = response.result.value
                        if result?["success"] as! Bool {
                            dispatch_async(dispatch_get_main_queue(), onSuccess)
                        }else{
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                onError(code: result?["code"] as? String)
                            })
                        }

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
