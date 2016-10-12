//
//  ChatRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlecrimCoreData

class ChatRequester2: BasicRequester {
    
    static let sharedInstance = ChatRequester2()
    
    fileprivate let _urlMap: [String: String] = [
        "chatlist": "list",
        "update": "update",
        "history": "history",
        "start": "start",
        "new": "speak",
        "roster_update": "<rosterID>/update"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "chat"
    }
    
    var privateQueue: DispatchQueue {
        return ChatModelManger.sharedManager.workQueue
    }
    
    override func urlForName(_ name: String, param: [String : String]? = nil) -> String {
        if name == "new" {
            return "\(kProtocalName)://\(kHostName):\(kChatPortName)/chat/speak"
        } else {
            return super.urlForName(name, param: param)
        }
    }
    
    override func internalErrorHandler(_ error: NSError) -> NSError? {
        if let url = (error.userInfo[NSURLErrorFailingURLErrorKey] as? URL), url.absoluteString.hasSuffix("/chat/update") {
            if error.code == -999 {
                return nil
            } else {
                return error
            }
        } else {
            return error
        }
    }
    
    func getCachedAudioDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDirectory = paths[0] as NSString
        let targetFolder = cacheDirectory.appendingPathComponent("record_audio_cache")
        do {
            if !FileManager.default.fileExists(atPath: targetFolder) {
                try FileManager.default.createDirectory(atPath: targetFolder, withIntermediateDirectories: false, attributes: nil)
            }
        }catch{
            return cacheDirectory as String
        }
        return targetFolder
    }
    
    func postNewChatRecord(_ chatType: String, messageType: String, targetID: String, image: UIImage?=nil, audio: URL?=nil, textContent: String? = nil, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) {
        var param: [String: AnyObject] = [
            "chat_type": chatType as AnyObject,
            "message_type": messageType as AnyObject,
            "target_id": targetID as AnyObject
        ]
        if messageType == "image" {
            param["image"] = image!
        } else if messageType == "audio" {
            param["audio"] = audio! as AnyObject?
        } else if messageType == "text" {
            param["text_content"] = textContent! as AnyObject?
        }
        upload(
            urlForName("new"),
            parameters: param,
            responseDataField: "message",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getChatList(_ onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(
            urlForName("chatlist"),
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    lazy var listenManager: Alamofire.SessionManager = {
       let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3600
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    func listen(_ queue: DispatchQueue, unread: Int = 0, curFocusedChat: Int32 = 0, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        let url = "\(kProtocalName)://\(kHostName):\(kChatPortName)/chat/update"
        let mutableRequest = NSMutableURLRequest(url: URL(string: url)!)
        mutableRequest.timeoutInterval = 3600
        var param: [String: Any] = ["unread": unread]
        if curFocusedChat > 0 {
            param["focused"] = Int(curFocusedChat)
        }
        // TODO: mutable request
        return post(
            url,
            parameters: param,
            withManager: self.listenManager,
            encoding: URLEncoding.default,
            responseQueue: queue,
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getChatHistories(_ rosterItemID: Int32, skips: Int, limit: Int, onSucces: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("history"),
            parameters: ["roster": "\(rosterItemID)", "skips": "\(skips)", "limit": "\(limit)"],
            responseQueue: privateQueue,
            responseDataField: "data",
            onSuccess: onSucces, onError: onError
        )
    }
    
    func startChat(_ targetID: String, chatType: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(
            urlForName("start"),
            parameters: ["target_id": targetID, "chat_type": chatType],
            responseQueue: self.privateQueue,
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func postUpdateUserRelationSettings(_ rosterID: String, remark_name: String, alwaysOnTop: Bool, noDisturbing: Bool, onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(
            urlForName("roster_update", param: ["rosterID": rosterID]),
            parameters: ["nick_name": remark_name, "always_on_top": alwaysOnTop, "no_disturbing": noDisturbing],
            onSuccess: onSuccess, onError: onError)
    }
}

