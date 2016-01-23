//
//  NewsRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/27.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class NewsURLMaker: AccountURLMaker {
    
    static let sharedMaker = NewsURLMaker()
    
    init() {
        super.init(user: nil)
    }
    
    /**
     获取最新的资讯的URL
     
     - returns: String格式
     */
    func getLatestNewsList() -> String {
        return website + "/news"
    }
    /**
     获取资讯的评论列表
     
     - parameter newsID: 需要输入制定的news的id
     
     - returns: String格式的网址
     */
    func getNewsCommentList(newsID: String) -> String {
        return website + "/news/\(newsID)/comments"
    }
    
    /**
     发布评论
     
     - parameter newsID: 需要制定被评论的资讯
     
     - returns: String格式的网址
     */
    func postComment(newsID: String) -> String {
        return website + "/news/\(newsID)/post_comments"
    }
}



class NewsRequester: AccountRequester {
    
    static let newsRequester = NewsRequester()
    /// 每次获取的最大News最大数量
    let fetchLimit = 20
    
    /**
     获取最新的NewsList
     
     - parameter dateThreshold: 时间阈值
     - parameter onSuccess:     成功时调用的closure
     - parameter onError:       失败时调用的closure
     */
    func getLatestNewsList(dateThreshold: NSDate, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let opType = "latest"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = NewsURLMaker.sharedMaker.getLatestNewsList()
        manager.request(.GET, requestURLStr,
            parameters: ["op_type": opType,
            "date_threshold": dtStr, "limit": "\(fetchLimit)"])
            .responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "news", onSuccess: onSuccess, onError: onError)
        }
    }
    
    func getMoreNewsList(dateThreshold: NSDate, onSuccess: (JSON?)->(),
        onError: (code: String?)->()) {
        let opType = "more"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = NewsURLMaker.sharedMaker.getLatestNewsList()
        manager.request(.GET, requestURLStr,
            parameters: ["op_type": opType,
                "date_threshold": dtStr, "limit": "\(fetchLimit)"])
            .responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "news", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取制定的id的资讯下面的评论
     
     - parameter dateThreshold: 时间阈值，将获取这个时间节点之后的新评论
     - parameter newsID:        newsID
     - parameter onSuccess:     成功之后的回调
     - parameter onError:       失败之后的回调
     */
    func getMoreNewsComment(dateThreshold: NSDate, newsID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let opType = "more"
        let dtStr = STRDate(dateThreshold)
        let requestURLStr = NewsURLMaker.sharedMaker.getNewsCommentList(newsID)
        manager.request(.GET, requestURLStr, parameters: ["op_type": opType,
            "date_threshold": dtStr, "limit": "\(fetchLimit)"]).responseJSON { (response) -> Void in
                self.resultValueHandler(response.result, dataFieldName: "comments", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     对一篇资讯发布评论
     
     - parameter newsID:        被回复的news的id
     - parameter content:       回复的内容，可以为空
     - parameter image:         回复的图片
     - parameter responseTo:    回复给另一评论内容
     - parameter onSuccess:     成功后调用的closure
     - parameter onError:       失败后调用的closure
     */
    func postCommentToNews(newsID: String, content: String?, image: UIImage?, responseTo: String?, informOf: [String]?, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = NewsURLMaker.sharedMaker.postComment(newsID)
        if content == nil && image == nil {
            assertionFailure()
        }
        manager.upload(.POST, urlStr, multipartFormData: { (data) -> Void in
            if content != nil {
                data.appendBodyPart(data: content!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "content")
            }
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
}