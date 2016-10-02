//
//  SettingsRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class SettingsRequester: BasicRequester {
    static let sharedInstance = SettingsRequester()
    
    fileprivate let _urlMap: [String: String] = [
        "settings": "settings"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "settings"
    }
    
    func updatePersonMineSettings(_ onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return get(urlForName("settings"), responseDataField: "settings", onSuccess: onSuccess, onError: onError)
    }
    
    func syncPersonMineSettings(_ param: [String: Any], onSuccess: @escaping (JSON?)->(), onError: @escaping (_ code: String?)->()) -> Request {
        return post(
            urlForName("settings"),
            parameters: param,
            onSuccess: onSuccess, onError: onError
        )
    }
    
}
