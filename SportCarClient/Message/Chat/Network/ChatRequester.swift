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
    
    private let _urlMap: [String: String] = [
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
    
    var privateQueue: dispatch_queue_t {
        return ChatModelManger.sharedManager.workQueue
    }
    
    override func urlForName(name: String, param: [String : String]? = nil) -> String {
        if name == "new" {
            return "\(kProtocalName)://\(kHostName):\(kChatPortName)/chat/speak"
        } else {
            return super.urlForName(name, param: param)
        }
    }
    
    override func internalErrorHandler(error: NSError) -> NSError? {
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey]?.absoluteString where url.hasSuffix("/chat/update") {
            print(error)
            if error.code == -999 {
                return nil
            } else {
                return error
            }
        } else {
            return error
        }
    }
    
    @available(*, deprecated=1)
    func download_audio_file_async(chatRecord: ChatRecord, onComplete:(record: ChatRecord, localURL: NSURL)->(), onError: (record: ChatRecord)->()) {
        // 首先查看是否已经有local副本存在
//        if let local = chatRecord.audioLocal {
//            if let localPath = NSURL(string: local)?.path {
//                let filename = localPath.split("/").last()!
//                let cacheFilePath = (getCachedAudioDirectory() as AnyObject).stringByAppendingPathComponent(filename)
//                if NSFileManager.defaultManager().fileExistsAtPath(cacheFilePath) {
//                    onComplete(record: chatRecord, localURL: NSURL(string: cacheFilePath)!)
//                    return
//                }
//            }
//        }
//        let urlStr = chatRecord.audio
//        var target_URL: NSURL = NSURL()
//        manager.download(.GET, SFURL(urlStr!)!.absoluteString, destination: { (tmpURL, response) -> NSURL in
//            let pathComponent = response.suggestedFilename ?? (NSUUID().UUIDString + ".m4a")
//            let cacheFilePath = (self.getCachedAudioDirectory() as AnyObject).stringByAppendingPathComponent(pathComponent)
//            target_URL = NSURL(fileURLWithPath: cacheFilePath)
//            return target_URL
//        }).response { (_, _, _, err) -> Void in
//            if err == nil {
//                onComplete(record: chatRecord, localURL: target_URL)
//            }else{
//                if err?.code == 516 {
//                    onComplete(record: chatRecord, localURL: target_URL)
//                }
//                onError(record: chatRecord)
//            }
//        }
    }
    
    func getCachedAudioDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cacheDirectory: AnyObject = paths[0]
        let targetFolder = cacheDirectory.stringByAppendingPathComponent("record_audio_cache")
        do {
            if !NSFileManager.defaultManager().fileExistsAtPath(targetFolder) {
                try NSFileManager.defaultManager().createDirectoryAtPath(targetFolder, withIntermediateDirectories: false, attributes: nil)
            }
        }catch{
            return cacheDirectory as! String
        }
        return targetFolder
    }
    
    func postNewChatRecord(chatType: String, messageType: String, targetID: String, image: UIImage?=nil, audio: NSURL?=nil, textContent: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        var param: [String: AnyObject] = [
            "chat_type": chatType,
            "message_type": messageType,
            "target_id": targetID
        ]
        if messageType == "image" {
            param["image"] = image!
        } else if messageType == "audio" {
            param["audio"] = audio!
        } else if messageType == "text" {
            param["text_content"] = textContent!
        }
        upload(
            urlForName("new"),
            parameters: param,
            responseDataField: "message",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getChatList(onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(
            urlForName("chatlist"),
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    lazy var listenManager: Alamofire.Manager = {
       let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 3600
        return Alamofire.Manager(configuration: configuration)
    }()
    
    func listen(queue: dispatch_queue_t, unread: Int = 0, curFocusedChat: Int32 = 0, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        let url = "\(kProtocalName)://\(kHostName):\(kChatPortName)/chat/update"
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        mutableRequest.timeoutInterval = 3600
        var param: [String: AnyObject] = ["unread": unread]
        if curFocusedChat > 0 {
            param["focused"] = Int(curFocusedChat)
        }
        return post(
            mutableRequest,
            parameters: param,
            withManager: self.listenManager,
            responseDataField: "data",
            responseQueue: queue,
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getChatHistories(rosterItemID: Int32, skips: Int, limit: Int, onSucces: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return get(
            urlForName("history"),
            parameters: ["roster": "\(rosterItemID)", "skips": "\(skips)", "limit": "\(limit)"],
            responseQueue: privateQueue,
            responseDataField: "data",
            onSuccess: onSucces, onError: onError
        )
    }
    
    func startChat(targetID: String, chatType: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(
            urlForName("start"),
            parameters: ["target_id": targetID, "chat_type": chatType],
            responseQueue: self.privateQueue,
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func postUpdateUserRelationSettings(rosterID: String, remark_name: String, alwaysOnTop: Bool, noDisturbing: Bool, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return post(
            urlForName("roster_update", param: ["rosterID": rosterID]),
            parameters: ["nick_name": remark_name, "always_on_top": alwaysOnTop, "no_disturbing": noDisturbing],
            onSuccess: onSuccess, onError: onError)
    }
}
//
//class ChatURLMaker {
//    let chatWebsite = "\(kProtocalName)://\(kHostName):\(kChatPortName)"
//    let website = "\(kProtocalName)://\(kHostName):\(kPortName)"
//    
//    static let sharedMaker = ChatURLMaker()
//    
//    func postNewChatRecord() -> String{
//        return chatWebsite + "/chat/speak"
//    }
//    
//    func updateChat() -> String {
//        return chatWebsite + "/chat/update"
//    }
//    
//    func chatList() -> String {
//        return website + "/chat/list"
//    }
//    
//    func chatSettings(targetUserID: String) -> String {
//        return website + "/profile/\(targetUserID)/settings"
//    }
//    
//    func groupChatCreate() -> String {
//        return website + "/club/create"
//    }
//    
//    func clubInfo(clubID: String) -> String {
//        return website + "/club/\(clubID)/info"
//    }
//    
//    func clubList() -> String {
//        return website + "/club/list"
//    }
//    
//    func clubDiscover() -> String {
//        return website + "/club/discover"
//    }
//    
//    func clubUpdate(clubID: String) -> String {
//        return website + "/club/\(clubID)/update"
//    }
//    
//    func clubQuit(clubID: String) -> String {
//        return website + "/club/\(clubID)/quit"
//    }
//    
//    func clubMembers(clubID: String) -> String {
//        return website + "/club/\(clubID)/members"
//    }
//    
//    func clubAuth(clubID: String) -> String {
//        return website + "/club/\(clubID)/auth"
//    }
//    
//    func unreadInformation() -> String {
//        return website + "/chat/unread"
//    }
//    
//    func chatHistory() -> String {
//        return website + "/chat/history"
//    }
//    
//    func chatUnreadSync() -> String {
//        return website + "/chat/unread/sync"
//    }
//    
//    func getNotifications() -> String {
//        return website + "/notification/"
//    }
//    
//    func markNotificationRead(notifID: String) -> String {
//        return website + "/notification/\(notifID)"
//    }
//    
//    func clearNotificationUnread() -> String {
//        return website + "/notification/clear"
//    }
//}
//
//
//@available(*, deprecated=1)
//class ChatRequester: AccountRequester {
//    
//    static let requester = ChatRequester()
//    
//    
//    let privateQueue = ChatModelManger.sharedManager.workQueue
//    var notificationQueue: dispatch_queue_t {
//        return privateQueue
//    }
//    
//    weak var chatRequest: Request?
//    func startListenning(onMessageCome: (JSON)->(), onError: (code: String?)->()) {
//        dispatch_async(privateQueue) { () -> Void in
//            self.updateChat(onMessageCome, onError: onError)
//        }
//    }
//    
//    func updateChat(onMessageCome: (JSON)->(), onError: (code: String?)->()) {
//        let urlStr = ChatURLMaker.sharedMaker.updateChat()
//        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
//        mutableRequest.timeoutInterval = 3600
//        chatRequest = manager.request(.POST, mutableRequest).responseJSON { (response) -> Void in
//            switch response.result {
//            case .Success(let value):
//                let data = JSON(value)
//                if data["success"].boolValue {
//                    dispatch_async(self.privateQueue, { () -> Void in
//                        onMessageCome(data["messages"])
//                    })
//                }else{
//                    dispatch_async(self.privateQueue, { () -> Void in
//                        onError(code: data["code"].string)
//                    })
////                    delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
//                }
//                break
//            case .Failure(_):
//                dispatch_async(self.privateQueue, { () -> Void in
//                    onError(code: "0000")
//                })
////                delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
//                break
//            }
//            // 继续请求
//            // 如果发生了错误，则延迟三秒以后再次发送请求
////            dispatch_after(delayTime, self.privateQueue, { () -> Void in
////                self.updateChat(onMessageCome, onError: onError)
////            })
//            dispatch_async(self.privateQueue, { () -> Void in
//                self.updateChat(onMessageCome, onError: onError)
//            })
//        }
//    }
//    
//    @available(*, deprecated=1)
//    func download_audio_file_async(chatRecord: ChatRecord, onComplete:(record: ChatRecord, localURL: NSURL)->(), onError: (record: ChatRecord)->()) {
//        // 首先查看是否已经有local副本存在
////        if let local = chatRecord.audioLocal {
////            if let localPath = NSURL(string: local)?.path {
////                let filename = localPath.split("/").last()!
////                let cacheFilePath = (getCachedAudioDirectory() as AnyObject).stringByAppendingPathComponent(filename)
////                if NSFileManager.defaultManager().fileExistsAtPath(cacheFilePath) {
////                    onComplete(record: chatRecord, localURL: NSURL(string: cacheFilePath)!)
////                    return
////                }
////            }
////        }
////        let urlStr = chatRecord.audio
////        var target_URL: NSURL = NSURL()
////        manager.download(.GET, SFURL(urlStr!)!.absoluteString, destination: { (tmpURL, response) -> NSURL in
////            let pathComponent = response.suggestedFilename ?? (NSUUID().UUIDString + ".m4a")
////            let cacheFilePath = (self.getCachedAudioDirectory() as AnyObject).stringByAppendingPathComponent(pathComponent)
////            target_URL = NSURL(fileURLWithPath: cacheFilePath)
////            return target_URL
////        }).response { (_, _, _, err) -> Void in
////            if err == nil {
////                onComplete(record: chatRecord, localURL: target_URL)
////            }else{
////                if err?.code == 516 {
////                    onComplete(record: chatRecord, localURL: target_URL)
////                }
////                onError(record: chatRecord)
////            }
////        }
//    }
//    
//    func getCachedAudioDirectory() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
//        let cacheDirectory: AnyObject = paths[0]
//        let targetFolder = cacheDirectory.stringByAppendingPathComponent("record_audio_cache")
//        do {
//            if !NSFileManager.defaultManager().fileExistsAtPath(targetFolder) {
//                try NSFileManager.defaultManager().createDirectoryAtPath(targetFolder, withIntermediateDirectories: false, attributes: nil)
//            }
//        }catch{
//            return cacheDirectory as! String
//        }
//        return targetFolder
//    }
//    
//    /**
//     发送聊天数据
//     
//     - parameter chatType:    聊天的类型：private or group
//     - parameter messageType: 消息的类型: text/ audio/ image
//     - parameter targetID:    目标id，当聊天类型是private时，为目标用户的id，当聊天类型是group时，为目标club的id
//     - parameter image:       需要上传的图片
//     - parameter audio:       需要上传的音频文件的本地文件URL
//     - parameter textContent: 需要上传的文本类容
//     - parameter onSuccess:   成功以后调用的closure
//     - parameter onError:     失败以后调用的closure
//     */
//    func postNewChatRecord(chatType: String, messageType: String, targetID: String, image: UIImage?=nil, audio: NSURL?=nil, textContent: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let urlStr = ChatURLMaker.sharedMaker.postNewChatRecord()
//        manager.upload(.POST, urlStr, multipartFormData: { (data) -> Void in
//            data.appendBodyPart(data: chatType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "chat_type")
//            data.appendBodyPart(data: messageType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "message_type")
//            data.appendBodyPart(data: targetID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "target_id")
//            if messageType == "image" {
//                data.appendBodyPart(data: UIImagePNGRepresentation(image!)!, name: "image", fileName: "uploaded_image.png", mimeType: "image/png")
//            } else if messageType == "audio" {
//                data.appendBodyPart(fileURL: audio!, name: "audio", fileName: "audio.m4a", mimeType: "audio/mp4")
////                data.appendBodyPart(fileURL: audio!, name: "audio")
//            } else if messageType == "text" {
//                data.appendBodyPart(data: textContent!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "text_content")
//            }
//            }) { (result) -> Void in
//                switch result {
//                case .Success(let upload, _, _):
//                    upload.responseJSON(completionHandler: { (response) -> Void in
//                        self.resultValueHandler(response.result, dataFieldName: "message", onSuccess: onSuccess, onError: onError)
//                    })
//                    break
//                case .Failure:
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        onError(code: "0000")
//                    })
//                    break
//                }
//        }
//    }
//    
//    /**
//     获取聊天配置信息
//     
//     - parameter targetUserID: 目标用户
//     - parameter onSuccess:    成功之后调用的closure
//     - parameter onError:      失败之后调用的closure
//     */
//    func getUserRelationSettings(targetUserID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let strURL = ChatURLMaker.sharedMaker.chatSettings(targetUserID)
//        manager.request(.GET, strURL).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "settings", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取俱乐部信息
//     
//     - parameter clubID:    俱乐部id
//     */
//    func getClubInfo(clubID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.clubInfo(clubID)
//        manager.request(.GET, url).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     更新聊天设置信息
//     
//     - parameter targetUserID:   目标用户id
//     - parameter remark_name:    备注名称
//     - parameter allowSeeStatus: 是否允许对方查看我的动态
//     - parameter seeHisStatus:   是否查看对方的动态
//     - parameter onSuccess:      成功以后调用的closure
//     - parameter onError:        失败以后调用的closure
//     */
//    func postUpdateUserRelationSettings(targetUserID: String, remark_name: String, allowSeeStatus: Bool, seeHisStatus: Bool, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let strURL = ChatURLMaker.sharedMaker.chatSettings(targetUserID)
//        manager.request(.POST, strURL, parameters: ["remark_name": remark_name, "allow_see_status": allowSeeStatus, "see_his_status": seeHisStatus]).responseJSON { (response) -> Void in
//            // No data binded
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     创建俱乐部
//     
//     - parameter clubName:    俱乐部名称
//     - parameter clubLogo:    俱乐部的标识
//     - parameter members:     俱乐部成员（id列表）
//     - parameter description: 俱乐部描述
//     - parameter onSuccess:   成功以后的调用的closure
//     - parameter onError:     失败以后调用的closure
//     */
//    func createNewClub(clubName: String, clubLogo: UIImage, members: [String], description: String, onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.groupChatCreate()
//        manager.upload(.POST, url, multipartFormData: { (form) -> Void in
//            form.appendBodyPart(data: clubName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "name")
//            form.appendBodyPart(data: UIImagePNGRepresentation(clubLogo)!, name: "logo", fileName: "logo.png", mimeType: "image/png")
//            form.appendBodyPart(data: try! JSON(members).rawData(), name: "members")
//            form.appendBodyPart(data: description.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "description")
//            }) { (result) -> Void in
//                switch result {
//                case .Success(let request, _, _):
//                    request.progress({ (_, written, total) -> Void in
//                        let progress = Float(written) / Float(total)
//                        onProgress(progress: progress)
//                    })
//                    request.responseJSON(completionHandler: { (response) -> Void in
//                        self.resultValueHandler(response.result, dataFieldName: "club", onSuccess: onSuccess, onError: onError)
//                    })
//                    break
//                case .Failure:
//                    onError(code: "0000")
//                    break
//                }
//        }
//    }
//    
//    /**
//     获取聊天列表的数据
//    */
//    func getChatList(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.chatList()
//        manager.request(.GET, url).responseJSON(self.privateQueue) { (response) in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
////        manager.request(.GET, url).responseJSON { (response) -> Void in
////            switch response.result {
////            case .Success(let value):
////                let data = JSON(value)
////                if data["success"].boolValue {
////                    dispatch_async(self.privateQueue, { () -> Void in
////                        onSuccess(data["data"])
////                    })
////                }else{
////                    dispatch_async(self.privateQueue, { () -> Void in
////                        onError(code: data["code"].string) 
////                    })
////                }
////                break
////            case .Failure:
////                dispatch_async(self.privateQueue, { () -> Void in
////                    onError(code: "0000")
////                })
////                break
////            }
////            
////        }
//    }
//
//    /**
//     获取当前用户的俱乐部列表
//     */
//    func getClubList(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.clubList()
//        manager.request(.GET, url).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "clubs", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func getClubListAuthed(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.clubList()
//        manager.request(.GET, url, parameters: ["authed": "y"]).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "clubs", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取未读消息信息
//     */
//    func getUnreadInformation(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.unreadInformation()
//        manager.request(.GET, url).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取聊天历史
//     
//     - parameter targetID:      目标id
//     - parameter chatType:      聊天类型
//     - parameter dateThreshold: 时间阈值，获取这个时间节点之前的消息
//     - parameter limit:         最大获取的数量
//     */
//    func getChatHistory(targetID: String, chatType: String, dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
//        let url = ChatURLMaker.sharedMaker.chatHistory()
//        return manager.request(.GET, url, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": "more", "limit": limit, "target_id": targetID, "chat_type": chatType]).responseJSON(self.privateQueue, completionHandler: { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "chats", onSuccess: onSuccess, onError: onError)
//        })
////            .response(queue: self.privateQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) -> Void in
////            self.resultValueHandler(response.result, dataFieldName: "chats", onSuccess: onSuccess, onError: onError)
////        }
////            .responseJSON { (response) -> Void in
////            self.resultValueHandler(response.result, dataFieldName: "chats", onSuccess: onSuccess, onError: onError)
////        }
//    }
//    
//    /**
//     更新群聊设置
//     */
//    
//    func updateClubLogo(club: Club, newLogo: UIImage, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.clubUpdate(club.ssidString)
//        manager.upload(.POST, url, multipartFormData: { (form) -> Void in
//            form.appendBodyPart(data: UIImagePNGRepresentation(newLogo)!, name: "logo", fileName: "new_logo.png", mimeType: "image/png")
//            }) { (result) -> Void in
//                switch result {
//                case .Success(let request, _, _):
//                    request.responseJSON(completionHandler: { (response) -> Void in
//                        self.resultValueHandler(response.result, dataFieldName: "logo", onSuccess: onSuccess, onError: onError)
//                    })
//                case .Failure:
//                    onError(code: "0000")
//                }
//        }
//    }
//    
//    func updateClubSettings(
//        club: Club,
//        onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//            let url = ChatURLMaker.sharedMaker.clubUpdate(club.ssidString)
//            let params: [String: AnyObject] = [
//                "only_host_can_invite": club.onlyHostCanInvite,
//                "show_members_to_public": club.showMembers,
//                "nick_name": club.remarkName ?? MainManager.sharedManager.hostUser!.nickName!,
//                "show_nick_name": club.showNickName,
//                "no_disturbing": club.noDisturbing,
//                "always_on_top": club.alwayOnTop,
//                "name": club.name!,
//                "description": club.clubDescription!
//            ]
//            manager.request(.POST, url, parameters: params, encoding: .JSON).responseJSON { (response) -> Void in
//                self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//            }
//    }
//    
//    /**
//     俱乐部发现
//     
//     - parameter queryType: 筛选类型，有效参数为nearby/value/members/average/beauty/recent
//     - parameter skip:      跳过前skip个结果
//     - parameter limit:     最大获取的数量
//     */
//    func discoverClub(queryType: String, skip: Int, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let url = ChatURLMaker.sharedMaker.clubDiscover()
//        manager.request(.GET, url, parameters: ["query_type": queryType, "skip": skip, "limit": limit]).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func getNotifications(threshold: NSDate, limit: Int, opType: String, dateFix: String = "", onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
//        let url = ChatURLMaker.sharedMaker.getNotifications()
//        let params: [String : AnyObject] = [
//            "date_threshold": STRDate(threshold),
//            "limit": limit,
//            "op_type": opType,
//            "date_fix": dateFix
//        ]
//        return manager.request(.GET, url, parameters: params)
//            .response(queue: self.notificationQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) -> Void in
//                self.resultValueHandler(response.result, dataFieldName: "notifications", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func notifMarkRead(notifID:String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
//        let url = ChatURLMaker.sharedMaker.markNotificationRead(notifID)
//        return manager.request(.POST, url).responseJSON(notificationQueue, completionHandler: { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        })
//    }
//    
//    /**
//     变更俱乐部的成员
//     
//     - parameter members:   删除或者新增的成员的列表
//     - parameter opType:    add/delete
//     */
//    func updateClubMembers(clubID: String, members: [String], opType: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
//        let url = ChatURLMaker.sharedMaker.clubMembers(clubID)
//        return manager.request(.POST, url, parameters: ["op_type": opType, "target_users": members], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        })
//    }
//    
//    /**
//     认证车辆
//     */
//    func clubAuth(clubID: String, district: String, description: String, onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()) -> Request {
//        let url = ChatURLMaker.sharedMaker.clubAuth(clubID)
//        return manager.request(.POST, url, parameters: ["city": district, "description": description], encoding: .JSON)
//            .progress({ (_, written, total) -> Void in
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    let progress = Float(written) / Float(total)
//                    onProgress(progress: progress)
//                })
//            })
//            .responseJSON(completionHandler: { (response) -> Void in
//                self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//            })
//    }
//    
//    
//    func clubQuit(clubID: String, newHostID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request{
//        let url = ChatURLMaker.sharedMaker.clubQuit(clubID)
//        return manager.request(.POST, url, parameters: ["new_host": newHostID], encoding: .JSON).responseJSON(self.privateQueue) { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func clearNotificationUnreadNum(onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
//        let url = ChatURLMaker.sharedMaker.clearNotificationUnread()
//        return manager.request(.POST, url).responseJSON(completionHandler: { (response) in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        })
//    }
//}