//
//  PersonRequest.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON

class PersonURLMaker: AccountURLMaker {
    
    static let sharedMaker = PersonURLMaker(user: nil)
    
    func getAuthedCars(userID: String) -> String{
        return website + "/profile/\(userID)/authed_cars"
    }
    
    func getBlackList() -> String{
        return website + "/profile/blacklist"
    }
    
    func updatePersonMineSettings() -> String {
        return website + "/settings/"
    }
    
    func postCorporationUserApplication() -> String {
        return website + "/profile/auth/corporation"
    }
    
    func profileModify() -> String{
        return website + "/profile/modify"
    }
}


class PersonRequester: AccountRequester{
    
    static let requester = PersonRequester()
    
    /**
     获取给定id的用户的所有认证车辆
     
     - parameter userID:    指定用户的id
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func getAuthedCars(userID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = PersonURLMaker.sharedMaker.getAuthedCars(userID)
        manager.request(.GET, strURL).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "cars", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取当前用户的黑名单，采用分页获取
     
     - parameter dateThreshold: 日期阈值
     - parameter limit:         每次获取的最大数量
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getBlackList(dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = PersonURLMaker.sharedMaker.getBlackList()
        let DTStr = STRDate(dateThreshold)
        manager.request(.GET, urlStr, parameters: ["date_threshold": DTStr, "op_type": "more", "limit": limit]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "users", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取服务器上存储的设施
     
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func updatePersonMineSettings(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = PersonURLMaker.sharedMaker.updatePersonMineSettings()
        manager.request(.GET, urlStr).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "settings", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     同步本地设置
     
     - parameter param:     上传的参数
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func syncPersonMineSettings(param: [String: AnyObject], onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = PersonURLMaker.sharedMaker.updatePersonMineSettings()
        manager.request(.POST, urlStr, parameters: param).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     申请成为企业用户，需要上传三张图片，三张图片按照营业执照-身份证-补充信息的顺序排列
     
     - parameter images:    待上传的图片
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func postCorporationUserApplication(images: [UIImage], onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        if images.count != 3 {
            assertionFailure()
        }
        let urlStr = PersonURLMaker.sharedMaker.postCorporationUserApplication()
        manager.upload(.POST, urlStr, multipartFormData: { (form) -> Void in
            form.appendBodyPart(data: UIImagePNGRepresentation(images[0])!, name: "license_image", fileName: "image1.png", mimeType: "image/png")
            form.appendBodyPart(data: UIImagePNGRepresentation(images[1])!, name: "id_card_image", fileName: "image2.png", mimeType: "image/png")
            form.appendBodyPart(data: UIImagePNGRepresentation(images[2])!, name: "other_info_image", fileName: "image3.png", mimeType: "image/png")
            }) { (result) -> Void in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
                    })
                    break
                case .Failure(let error):
                    print(error)
                    onError(code: "0000")
                    break
                }
        }
    }
    
    /**
     修改当期当前登陆的用户的信息，允许修改的属性包括'nick_name', 'avatar', 'avatar_club', 'avatar_car', 'signature',
     'job', 'district'
     
     - parameter param:     上传参数
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func profileModifiy(param: [String: AnyObject], onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = PersonURLMaker.sharedMaker.profileModify()
        manager.request(.POST, strURL, parameters: param).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func profileModifyUploadAvatar(avatar: UIImage, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = PersonURLMaker.sharedMaker.profileModify()
        manager.upload(.POST, strURL, multipartFormData: { (form) -> Void in
            form.appendBodyPart(data: UIImagePNGRepresentation(avatar)!, name: "avatar", fileName: "avatar.png", mimeType: "image/png")
            }) { (result) -> Void in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        self.resultValueHandler(response.result, dataFieldName: "avatar", onSuccess: onSuccess, onError: onError)
                    })
                    break
                case .Failure(let error):
                    print(error)
                    onError(code: "0000")
                    break
                }
        }
    }
}
