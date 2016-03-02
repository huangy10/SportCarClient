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

class ChatURLMaker {
    let chatWebsite = "\(kProtocalName)://\(kHostName):\(kChatPortName)"
    let website = "\(kProtocalName)://\(kHostName):\(kPortName)"
    
    static let sharedMaker = ChatURLMaker()
    
    func postNewChatRecord() -> String{
        return chatWebsite + "/chat/speak"
    }
    
    func updateChat() -> String {
        return chatWebsite + "/chat/update"
    }
    
    func chatList() -> String {
        return website + "/chat/list"
    }
    
    func chatSettings(targetUserID: String) -> String {
        return website + "/profile/\(targetUserID)/settings"
    }
    
    func groupChatCreate() -> String {
        return website + "/club/create"
    }
    
    func clubInfo(clubID: String) -> String {
        return website + "/club/\(clubID)/info"
    }
    
    func clubList() -> String {
        return website + "/club/list"
    }
    
    func unreadInformation() -> String {
        return website + "/chat/unread"
    }
    
    func chatHistory() -> String {
        return website + "/chat/history"
    }
    
    func chatUnreadSync() -> String {
        return website + "/chat/unread/sync"
    }
}


class ChatRequester: AccountRequester {
    
    static let requester = ChatRequester()
    
    let privateQueue = dispatch_queue_create("chat_updater", DISPATCH_QUEUE_SERIAL)
    
    func startListenning(onMessageCome: (JSON)->(), onError: (code: String?)->()) {
        dispatch_async(privateQueue) { () -> Void in
            self.updateChat(onMessageCome, onError: onError)
        }
    }
    
    func updateChat(onMessageCome: (JSON)->(), onError: (code: String?)->()) {
        let urlStr = ChatURLMaker.sharedMaker.updateChat()
        manager.request(.POST, urlStr).responseJSON { (response) -> Void in
            var delayTime: dispatch_time_t = DISPATCH_TIME_NOW
            switch response.result {
            case .Success(let value):
                let data = JSON(value)
                if data["success"].boolValue {
                    dispatch_async(self.privateQueue, { () -> Void in
                        onMessageCome(data["messages"])
                    })
                }else{
                    dispatch_async(self.privateQueue, { () -> Void in
                        onError(code: data["code"].string)
                    })
                    delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
                }
                break
            case .Failure(let err):
                print(err)
                dispatch_async(self.privateQueue, { () -> Void in
                    onError(code: "0000")
                })
                delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 3)
                break
            }
            // 继续请求
            // 如果发生了错误，则延迟三秒以后再次发送请求
            dispatch_after(delayTime, self.privateQueue, { () -> Void in
                self.updateChat(onMessageCome, onError: onError)
            })
//            dispatch_async(self.privateQueue, { () -> Void in
//                self.updateChat(onMessageCome, onError: onError)
//            })
        }
    }
    
    func download_audio_file_async(chatRecord: ChatRecord, onComplete:(record: ChatRecord, localURL: NSURL)->(), onError: (record: ChatRecord)->()) {
        let urlStr = chatRecord.audio
        var target_URL: NSURL = NSURL()
        manager.download(.GET, SFURL(urlStr!)!.absoluteString, destination: { (tmpURL, response) -> NSURL in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename
            target_URL = directoryURL.URLByAppendingPathComponent(pathComponent!)
            return target_URL
        }).response { (_, _, _, err) -> Void in
            if err == nil {
                onComplete(record: chatRecord, localURL: target_URL)
            }else{
                onError(record: chatRecord)
            }
        }
    }
    
    /**
     发送聊天数据
     
     - parameter chatType:    聊天的类型：private or group
     - parameter messageType: 消息的类型: text/ audio/ image
     - parameter targetID:    目标id，当聊天类型是private时，为目标用户的id，当聊天类型是group时，为目标club的id
     - parameter image:       需要上传的图片
     - parameter audio:       需要上传的音频文件的本地文件URL
     - parameter textContent: 需要上传的文本类容
     - parameter onSuccess:   成功以后调用的closure
     - parameter onError:     失败以后调用的closure
     */
    func postNewChatRecord(chatType: String, messageType: String, targetID: String, image: UIImage?=nil, audio: NSURL?=nil, textContent: String? = nil, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let urlStr = ChatURLMaker.sharedMaker.postNewChatRecord()
        manager.upload(.POST, urlStr, multipartFormData: { (data) -> Void in
            data.appendBodyPart(data: chatType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "chat_type")
            data.appendBodyPart(data: messageType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "message_type")
            data.appendBodyPart(data: targetID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "target_id")
            if messageType == "image" {
                data.appendBodyPart(data: UIImagePNGRepresentation(image!)!, name: "image", fileName: "uploaded_image.png", mimeType: "image/png")
            }else if messageType == "audio" {
                data.appendBodyPart(fileURL: audio!, name: "audio", fileName: "audio.m4a", mimeType: "audio/mp4")
//                data.appendBodyPart(fileURL: audio!, name: "audio")
            }else{
                data.appendBodyPart(data: textContent!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "text_content")
            }
            }) { (result) -> Void in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        self.resultValueHandler(response.result, dataFieldName: "message", onSuccess: onSuccess, onError: onError)
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
     获取聊天配置信息
     
     - parameter targetUserID: 目标用户
     - parameter onSuccess:    成功之后调用的closure
     - parameter onError:      失败之后调用的closure
     */
    func getUserRelationSettings(targetUserID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = ChatURLMaker.sharedMaker.chatSettings(targetUserID)
        manager.request(.GET, strURL).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "settings", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取俱乐部信息
     
     - parameter clubID:    俱乐部id
     */
    func getClubInfo(clubID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.clubInfo(clubID)
        manager.request(.GET, url).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     更新聊天设置信息
     
     - parameter targetUserID:   目标用户id
     - parameter remark_name:    备注名称
     - parameter allowSeeStatus: 是否允许对方查看我的动态
     - parameter seeHisStatus:   是否查看对方的动态
     - parameter onSuccess:      成功以后调用的closure
     - parameter onError:        失败以后调用的closure
     */
    func postUpdateUserRelationSettings(targetUserID: String, remark_name: String, allowSeeStatus: Bool, seeHisStatus: Bool, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let strURL = ChatURLMaker.sharedMaker.chatSettings(targetUserID)
        manager.request(.POST, strURL, parameters: ["remark_name": remark_name, "allow_see_status": allowSeeStatus, "see_his_status": seeHisStatus]).responseJSON { (response) -> Void in
            // No data binded
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     创建俱乐部
     
     - parameter clubName:    俱乐部名称
     - parameter clubLogo:    俱乐部的标识
     - parameter members:     俱乐部成员（id列表）
     - parameter description: 俱乐部描述
     - parameter onSuccess:   成功以后的调用的closure
     - parameter onError:     失败以后调用的closure
     */
    func createNewClub(clubName: String, clubLogo: UIImage, members: [String], description: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.groupChatCreate()
        manager.upload(.POST, url, multipartFormData: { (form) -> Void in
            form.appendBodyPart(data: clubName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "name")
            form.appendBodyPart(data: UIImagePNGRepresentation(clubLogo)!, name: "logo", fileName: "logo.png", mimeType: "image/png")
            form.appendBodyPart(data: try! JSON(members).rawData(), name: "members")
            form.appendBodyPart(data: description.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "description")
            }) { (result) -> Void in
                switch result {
                case .Success(let request, _, _):
                    request.responseJSON(completionHandler: { (response) -> Void in
                        self.resultValueHandler(response.result, dataFieldName: "club", onSuccess: onSuccess, onError: onError)
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
     获取聊天列表的数据
    */
    func getChatList(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.chatList()
        manager.request(.GET, url).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(let value):
                let data = JSON(value)
                if data["success"].boolValue {
                    dispatch_async(self.privateQueue, { () -> Void in
                        onSuccess(data["data"])
                    })
                }else{
                    dispatch_async(self.privateQueue, { () -> Void in
                        onError(code: data["code"].string) 
                    })
                }
                break
            case .Failure(let err) :
                print(err)
                dispatch_async(self.privateQueue, { () -> Void in
                    onError(code: "0000")
                })
                break
            }
        }
    }
    
    /**
     获取当前用户的俱乐部列表
     */
    func getClubList(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.clubList()
        manager.request(.GET, url).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "clubs", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取未读消息信息
     */
    func getUnreadInformation(onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.unreadInformation()
        manager.request(.GET, url).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取聊天历史
     
     - parameter targetID:      目标id
     - parameter chatType:      聊天类型
     - parameter dateThreshold: 时间阈值，获取这个时间节点之前的消息
     - parameter limit:         最大获取的数量
     */
    func getChatHistory(targetID: String, chatType: String, dateThreshold: NSDate, limit: Int, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
        let url = ChatURLMaker.sharedMaker.chatHistory()
        manager.request(.GET, url, parameters: ["date_threshold": STRDate(dateThreshold), "op_type": "more", "limit": limit, "target_id": targetID, "chat_type": chatType]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "chats", onSuccess: onSuccess, onError: onError)
        }
    }
}