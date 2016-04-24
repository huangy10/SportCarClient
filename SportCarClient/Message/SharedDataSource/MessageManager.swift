//
//  MessageManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Kingfisher
import AlecrimCoreData
import Alamofire

/*
 In this new MessageManager, we reconstruct the model layer of the entire message module. Below are the major changes:
 1. Combine the listening queue of the notifications and chats
 2. Deprecate the polling of the notifications
 3. Simplify the interface of the manager
 4. Redefine the identifier system of the chats (private & group)
 */

class MessageManager {
    
    static let defaultManager = MessageManager()
    
    /// Current ongoing request to the server
    private weak var request: Request?
    
    /// Current status of the manager
    private var state: State = .IDLE
    
    /// The working queue of the manager
    private var queue: dispatch_queue_t! {
        return ChatModelManger.sharedManager.workQueue
    }
    
    private var manager: Manager {
        return ChatRequester.requester.manager
    }
    
    private var url: String {
        return ChatURLMaker.sharedMaker.updateChat()
    }
    
    var hostUser: User! {
        return MainManager.sharedManager.hostUser
    }
    
    var anonymous: Bool {
        return MainManager.sharedManager.hostUser == nil
    }
    
    func connect() {
        assert(!anonymous, "cannot connect to the chat server without logged in")
        // start listening on private queue
        state = .ONGOING
        dispatch_barrier_async(queue) { self.sync() }
        dispatch_async(queue) { self.listen() }
    }
    
    /**
     Synchronous the local storage of messages
     */
    private func sync() {
        guard !NSThread.isMainThread() else {
            state = .ERROR
            assertionFailure("Cannot listen the the chat server on main thread")
            return
        }
        guard state == .ONGOING else {
            return
        }
        let context = ChatModelManger.sharedManager.getOperationContext()
        var params: [String: AnyObject] = [:]
        if let chatLatestRequstDate = context.chatRecords.filter({$0.hostSSID == hostUser.ssid }).orderByDescending({$0.createdAt}).first()?.createdAt {
            params["chat"] = STRDate(chatLatestRequstDate)
        }
        if let notificationRequestDate = context.notifications.filter({ $0.hostSSID == hostUser.ssid }).orderByDescending({ $0.createdAt}).first()?.createdAt {
            params["notification"] = STRDate(notificationRequestDate)
        }
        // TODO: change the API url
        manager.request(.POST, url, parameters: params, encoding: .JSON).responseJSON(queue) { (response) in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                do {
                    try self.parse(json)
                } catch let err {
                    print(err)
                    self.state = .ERROR
                }
            case .Failure(let err):
                print(err)
                self.state = .ERROR
            }
        }
    }
    
    /**
     This function monitor the status of the server and request the realtime chat content
     */
    private func listen() {
        guard !NSThread.isMainThread() else {
            state = .ERROR
            assertionFailure("Cannot listen the the chat server on main thread")
            return
        }
        guard state == .ONGOING else {
            return
        }
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        // big enough so that it never timeout
        mutableRequest.timeoutInterval = 3600
        // send request to the server
        request = manager.request(.POST, mutableRequest).responseJSON(queue, completionHandler: { (response) in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                do {
                    try self.parse(json)
                } catch let err {
                    print(err)
                    self.state = .ERROR
                }
            case .Failure(let err):
                print(err)
                self.state = .ERROR
            }
            // re-send the request
            self.request = nil
            dispatch_async(self.queue) { self.listen() }
        })
    }
    
    func disconnect() {
        if let request = request {
            // if there is an ongoing request, cancel it
            request.cancel()
        }
        state = .IDLE
    }
    
    func parse(data: JSON) throws {
        if data["chatID"].exists() {
            try ChatParser().parse(data)
        } else {
            try NotificationParser().parse(data)
        }
        throw SSModelError.NotSupported
    }
    
    enum State {
        case IDLE, ONGOING, ERROR, OFFLINE
    }
}
