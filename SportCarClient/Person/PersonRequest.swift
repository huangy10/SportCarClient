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
}
