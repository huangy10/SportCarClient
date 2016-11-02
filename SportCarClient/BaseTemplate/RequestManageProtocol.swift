//
//  RequestManageMixin.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestManageMixin: class {
    var onGoingRequest: [String: Request] { set get }
    
    func registerReqeust(_ req: Request, forKey key: String)
    
    func clearAllRequest()
    
    func clearRequestForKey(_ key: String)
    
    func reqKeyFromFunctionName(withExtraID extraID: String, funcName: String) -> String
}

extension RequestManageMixin where Self: UIViewController {

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
    
    func reqKeyFromFunctionName(withExtraID extraID: String, funcName: String = #function) -> String {
        return "\(funcName)-\(extraID)"
    }
}

extension Request {
    func registerForRequestManage(_ manage: RequestManageMixin, forKey key: String = #function) {
        manage.registerReqeust(self, forKey: key)
    }
}
