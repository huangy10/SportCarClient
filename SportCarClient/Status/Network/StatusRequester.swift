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


internal class StatusURLMaker: AccountURLMaker {
    
    static let sharedMaker = StatusURLMaker(user: MainManager.sharedManager.hostUser!)
    
    
    func getStatusFollowList() -> String{
        return website + "/status"
    }
    
    func postNewStatus() -> String {
        return website + "/status/post"
    }
    
    func getStatusDetail(statusID: String) -> String {
        return website + "/status/\(statusID)"
    }
    
    func getStatusComments(statusID: String) -> String {
        return website + "/status/\(statusID)/comments"
    }
    
    func postComment(statusID: String) -> String {
        return website + "/status/\(statusID)/post_comments"
    }
    
    func getStatusListSimplified(userID: String) -> String{
        return website + "/profile/\(userID)/status"
    }
    
    func statusOperation(statusID: String) -> String {
        return website + "/status/\(statusID)/operation"
    }
}


class StatusRequester: AccountRequester {
    
    static let SRRequester: StatusRequester = StatusRequester()
    
    let fetchLimit = 20
    let privateQueue = dispatch_queue_create("status", DISPATCH_QUEUE_SERIAL)
    
    /**
     获取最新的status
     
     - parameter dateThreshold: 时间阈值，这里获取到的最新的状态将是在这个时间阈值之后发布的新的动态
     - parameter onSuccess:     成功后调用这个closure
     - parameter onError:       失败以后调用这个
     */
    func getLatestStatusList(dateThreshold: NSDate, queryType: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let opType = "latest"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = StatusURLMaker.sharedMaker.getStatusFollowList()
        manager.request(.GET, requestURLStr,
            parameters: ["date_threshold": dtStr, "limit": fetchLimit, "op_type": opType, "query_type": queryType]).responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func getMoreStatusList(dateThreshold: NSDate, queryType: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let opType = "more"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = StatusURLMaker.sharedMaker.getStatusFollowList()
        manager.request(.GET, requestURLStr,
            parameters: ["date_threshold": dtStr, "limit": fetchLimit, "op_type": opType, "query_type": queryType]).responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func getNearByStatus(
        dateThreshold: NSDate,
        opType: String, lat: Double,
        lon: Double, distance: Double,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback) -> Request {
        let dtStr = STRDate(dateThreshold)
        return manager.request(.GET, StatusURLMaker.sharedMaker.getStatusFollowList(), parameters: [
            "date_threshold": dtStr,
            "op_type": opType,
            "limit": fetchLimit,
            "lat": lat,
            "lon": lon,
            "distance": distance,
            "query_type": "nearby"
        ]).responseJSON(completionHandler: { (response) in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        })
    }
    
    /**
     发布新的状态
     
     - parameter content:         状态的文本内容
     - parameter images:          上传的图像
     - parameter car_id:          at的车的id
     - parameter lat:             地点的维度数据
     - parameter lon:             地点的精度数据
     - parameter loc_description: 地点描述
     - parameter onSuccess:       成功以后调用这个closure
     - parameter onError:         失败以后调用这个closure
     */
    func postNewStatus(content: String, images: [UIImage], car_id: String?, lat: Double?, lon: Double?, loc_description: String?, informOf: [String]?,
        onSuccess: (JSON?)->(), onError: (code: String?)->(), onProgress: (progress: Float)->()) {
        let urlStr = StatusURLMaker.sharedMaker.postNewStatus()
        manager.upload(.POST, urlStr, multipartFormData: { (data) -> Void in
            data.appendBodyPart(data: content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "content")
            var i = 1
            for image in images {
                data.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: "image\(i)", fileName: "image\(i)/png", mimeType: "image/png")
                i += 1
            }
            if car_id != nil {
                data.appendBodyPart(data: car_id!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "car_id")
            }
            if lat != nil {
                data.appendBodyPart(data: "\(lat!)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "lat")
            }
            if lon != nil {
                data.appendBodyPart(data: "\(lon!)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "lon")
            }
            if loc_description != nil {
                data.appendBodyPart(data: loc_description!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "location_description")
            }
            if informOf != nil && informOf!.count > 0{
                let informJSON = JSON(informOf!)
                data.appendBodyPart(data: try! informJSON.rawData(), name: "inform_of")
            }
            let hostUserID = MainManager.sharedManager.hostUserIDString!
            data.appendBodyPart(data: hostUserID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "user_id")
            
            }) { (let encodingResult) -> Void in
                switch encodingResult{
                case .Success(request: let upload, _, _):
                    upload.progress({ (bytesWritten, totalByteWritten, totalByteExpectedToWrite) -> Void in
                        let progress = Float(totalByteWritten) / Float(totalByteExpectedToWrite)
                        onProgress(progress: progress)
                    })
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        self.resultValueHandler(response.result, dataFieldName: "statusID", onSuccess: onSuccess, onError: onError)
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
    
    func getStatusDetail(statusID: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) {
        let url =  StatusURLMaker.sharedMaker.getStatusDetail(statusID)
        manager.request(.GET, url).responseJSON { (response) in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取制定的id的状态下面的评论
     
     - parameter dateThreshold: 时间阈值，将获取这个时间节点之后的新评论
     - parameter newsID:        newsID
     - parameter onSuccess:     成功之后的回调
     - parameter onError:       失败之后的回调
     */
    func getMoreStatusComment(dateThreshold: NSDate, statusID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let opType = "more"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = StatusURLMaker.sharedMaker.getStatusComments(statusID)
        manager.request(.GET, requestURLStr, parameters: ["op_type": opType,
            "date_threshold": dtStr, "limit": "\(fetchLimit)"]).responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "comments", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func postCommentToStatus(statusID: String, content: String, image: UIImage?, responseTo: String?, informOf: [String]?,  onSuccess: (JSON?)->(), onError: (code: String?)->())
        {
            let urlStr = StatusURLMaker.sharedMaker.postComment(statusID)
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
     根据发布者获取动态列表
     
     - parameter userID:        给定用户的id
     - parameter dateThreshold: 时间阈值
     - parameter limit:         最大获取数量
     - parameter onSuccess:     成功以后调用的closure
     - parameter onError:       失败以后调用的closure
     */
    func getStatusListSimplified(userID: String, carID: String?, dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = StatusURLMaker.sharedMaker.getStatusListSimplified(userID)
        var params: [String: AnyObject] = ["date_threshold": STRDate(dateThreshold), "limit": limit, "op_type": "more"]
        if carID != nil {
            params["filter_car"] = carID
        }
        manager.request(.GET, strURL, parameters: params).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     删除制定的id的状态，这个请求会在privatQueue上发送
     
     - parameter statusID:  目标id
     */
    func deleteStatus(statusID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        let url = StatusURLMaker.sharedMaker.statusOperation(statusID)
        return manager.request(.POST, url, parameters: ["op_type": "delete"])
            .response(queue: self.privateQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func likeStatus(statusID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        let url = StatusURLMaker.sharedMaker.statusOperation(statusID)
        return manager.request(.POST, url, parameters: ["op_type": "like"]).responseJSON(completionHandler: { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "like_info", onSuccess: onSuccess, onError: onError)
        })
    }
}