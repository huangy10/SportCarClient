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
    
    private let _urlMap: [String: String] = [
        "settings": "settings"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "settings"
    }
    
    func updatePersonMineSettings(onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return get(urlForName("settings"), responseDataField: "settings", onSuccess: onSuccess, onError: onError)
    }
    
    func syncPersonMineSettings(param: [String: AnyObject], onSuccess: (JSON?)->(), onError: (code: String?)->()) -> Request {
        return post(
            urlForName("settings"),
            parameters: param,
            onSuccess: onSuccess, onError: onError
        )
    }
    
}