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


class ActivityURLMaker: AccountURLMaker {
    static let sharedURLMaker = ActivityURLMaker(user: nil)
    //
    func activityMineList() -> String{
        return website + "/activity/mine"
    }
    
    func activityNearBy() -> String {
        return website + "/activity/discover"
    }
    
    func activityApplied() -> String {
        return website + "/activity/applied"
    }
    
    func activityDetail(actID: String) -> String {
        return website + "/activity/\(actID)"
    }
    
    func activitySendComment(actID: String) -> String {
        return website + "/activity/\(actID)/post_comment"
    }
    
    func activityDetailComment(actID: String) -> String {
        return website + "/activity/\(actID)/comments"
    }
    
    func createActivity() -> String {
        return website + "/activity/create"
    }
    
    func applyActivity(actID: String) -> String {
        return website + "/activity/\(actID)/apply"
    }
    
    func closeActivity(actID: String) -> String{
        return website + "/activity/\(actID)/close"
    }
    
    func activityOperation(actID: String) -> String {
        return website + "/activity/\(actID)/operation"
    }
}


class ActivityRequester: AccountRequester {
    
    static let requester = ActivityRequester()
    
    /**
     获取我发布的活动的列表，分页获取
     
     - parameter dateThreshold: 时间阈值
     - parameter op_type:       操作类型：latest/more
     - parameter limit:         最大获取的数量
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getMineActivityList(dateThreshold: NSDate, op_type: String, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activityMineList()
        let dtStr = STRDate(dateThreshold)
        manager.request(.GET, urlStr, parameters: ["limit": limit, "date_threshold": dtStr, "op_type": op_type]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "acts", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取用户附近的活动
     
     - parameter userLocation:  用户位置
     - parameter queryDistance: 搜索的最大距离
     - parameter skip:          跳过前若干个结果
     - parameter limit:         最大获取的数量
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getNearByActivities(userLocation: CLLocation, queryDistance: Double, skip: Int, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activityNearBy()
        let lat: Double = userLocation.coordinate.latitude
        let lon: Double = userLocation.coordinate.longitude
        manager.request(.GET, urlStr, parameters: ["lon": lon, "lat": lat, "query_distance": queryDistance, "limit": limit, "skip": skip]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "acts", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func getActivityApplied(dateThreshold: NSDate, op_type: String, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activityApplied()
        let dtStr = STRDate(dateThreshold)
        manager.request(.GET, urlStr, parameters: ["limit": limit, "date_threshold": dtStr, "op_type": op_type]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "acts", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取活动的详细信息
     
     - parameter actID:     活动id
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func getActivityDetail(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activityDetail(actID)
        manager.request(.GET, urlStr).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func sendActivityComment(actID: String, content: String, image: UIImage?, responseTo: String?, informOf: [String]?,  onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activitySendComment(actID)
        manager.upload(.POST, urlStr, multipartFormData: { (data) -> Void in
            
            data.appendBodyPart(data: content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "content")
            
            if image != nil {
                data.appendBodyPart(data: UIImagePNGRepresentation(image!)!, name: "image")
            }
            if responseTo != nil {
                data.appendBodyPart(data: responseTo!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "response_to")
            }
            if informOf != nil && informOf!.count > 0{
                let informJSON = JSON(informOf!)
                data.appendBodyPart(data: informJSON.stringValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "inform_of")
            }
            }) { (result) -> Void in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        switch response.result {
                        case .Success(let value):
                            let json = JSON(value)
                            if json["success"].boolValue == true {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    onSuccess(json["data"])
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    onError(code: json["code"].string)
                                })
                            }
                            break
                        case .Failure(let err):
                            print(err)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                onError(code: "0000")
                            })
                            break
                        }
                    })
                    break
                case .Failure(let error):
                    print(error)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        onError(code: "0000")
                    })
                    
                    break
                }
        }
    }
    /**
     活动活动评论列表，分页获取
     
     - parameter actID:         活动id
     - parameter dateThreshold: 时间阈值
     - parameter limit:         最大获取数量
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getActivityComments(actID: String, dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.activityDetailComment(actID)
        manager.request(.GET, urlStr, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": "more", "limit": limit]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "comments", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     创建活动
     
     - parameter name:       活动名称
     - parameter des:        活动描述
     - parameter informUser: at的用户
     - parameter maxAttend:  最多参加的
     - parameter startAt:    开始时间
     - parameter endAt:      结束时间
     - parameter clubLimit:  限制参与的俱乐部
     - parameter poster:     海报
     - parameter lat:        位置维度
     - parameter lon:        位置经度
     - parameter loc_des:    位置描述
     - parameter onSuccess:  成功以后调用的closure
     - parameter onError:    失败以后调用的closure
     */
    func createNewActivity(name: String, des: String, informUser: [String]?,  maxAttend: Int, startAt: NSDate, endAt: NSDate, clubLimit: String?, poster: UIImage, lat: Double, lon: Double, loc_des: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.createActivity()
        manager.upload(.POST, urlStr, multipartFormData: { (form) -> Void in
            // 必备信息
            form.appendBodyPart(data: name.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "name")
            form.appendBodyPart(data: des.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "description")
            form.appendBodyPart(data: "\(maxAttend)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "max_attend")
            form.appendBodyPart(data: STRDate(startAt).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "start_at")
            form.appendBodyPart(data: STRDate(endAt).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "end_at")
            form.appendBodyPart(data: UIImagePNGRepresentation(poster)!, name: "poster", fileName: "poster.png", mimeType: "image/png")
            // 位置数据
            let location = ["lat": lat, "lon": lon, "description": loc_des]
            form.appendBodyPart(data: try! JSON(location).rawData(), name: "location")
            // Optional
            if informUser != nil {
                let jsonList: String = JSON(informUser!).stringValue
                form.appendBodyPart(data: jsonList.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "inform_of")
            }
            if clubLimit != nil {
                form.appendBodyPart(data: clubLimit!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "club_limit")
            }
            }) { (result) -> Void in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        switch response.result {
                        case .Success(let value):
                            let json = JSON(value)
                            if json["success"].boolValue == true {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    onSuccess(json["id"])
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    onError(code: json["code"].string)
                                })
                            }
                            break
                        case .Failure(let err):
                            print(err)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                onError(code: "0000")
                            })
                            break
                        }
                    })
                    break
                case .Failure(let error):
                    print(error)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        onError(code: "0000")
                    })
                    
                    break
                }
        }
    }
    
    /**
     报名，或者取消报名活动
     
     - parameter actID:     活动id
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func postToApplyActivty(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.applyActivity(actID)
        manager.request(.POST, urlStr).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "join", onSuccess: onSuccess, onError: onError)
        }
    }

    /**
     关闭活动报名
     
     - parameter actID:     活动id
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func closeActivty(actID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ActivityURLMaker.sharedURLMaker.closeActivity(actID)
        manager.request(.POST, urlStr).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func activityOperation(actID: String, targetUserID: String, opType: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
        let url = ActivityURLMaker.sharedURLMaker.activityOperation(actID)
        return manager.request(.POST, url, parameters: ["op_type": opType, "target_user": targetUserID]).responseJSON(completionHandler: { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        })
    }
}