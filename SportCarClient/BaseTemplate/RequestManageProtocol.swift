//
//  RequestManageProtocol.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestManageProtocol: class {
    var onGoingRequest: [String: Request] { set get }
    
    func registerReqeust(_ req: Request, forKey key: String)
    
    func clearAllRequest()
    
    func clearRequestForKey(_ key: String)
}

extension RequestManageProtocol where Self: UIViewController {

    func registerReqeust(_ req: Request, forKey key: String) {
        clearRequestForKey(key)
        onGoingRequest[key] = req
    }
    
    func clearAllRequest() {
        for (_, req) in onGoingRequest {
            req.cancel()
        }
        
        onGoingRequest.removeAll()
    }
    
    func clearRequestForKey(_ key: String) {
        if let r = onGoingRequest[key] {
            r.cancel()
        }
    }
    
}

extension Request {
    func registerForRequestManage(_ manage: RequestManageProtocol, forKey key: String) {
        manage.registerReqeust(self, forKey: key)
    }
}
