//
//  BaseInMemModel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class BaseInMemModel: NSObject {
    var ssid: Int32
    var ssidString: String {
        return "\(ssid)"
    }
    
    class var idField: String {
        return ""
    }
    
    override init () {
        ssid = -1
        super.init()
    }
    
    /**
     从json数据中载入Model需要的数据
     
     - parameter data: json数据
     - parameter ctx:  所属的context
     */
    func loadDataFromJSON(_ data: JSON) throws -> Self {
        return self
    }
    
    func toJSONObject(_ detailLevel: Int) throws -> JSON {
        throw SSModelError.notImplemented
    }
    
    /**
     将这个对象转化成为json字符串
     
     - parameter detailLevel: 这个数值决定了最后导出的字符串中信息的详细程度
     
     - returns: json字符串
     */
    func toJSONString(_ detailLevel: Int) throws -> String {
        let json = try toJSONObject(detailLevel)
        if json.isEmpty {
            throw SSModelError.unknown
        }
        if let result = json.rawString() {
            return result
        } else {
            throw SSModelError.unknown
        }
    }
    
    /**
     从json字符串中恢复对象数据
     
     - parameter string:      字符串内容
     - parameter detailLevel: 详细程度
     */
    func fromJSONString(_ string: String, detailLevel: Int) throws -> Self {
        throw SSModelError.notImplemented
    }
    
    class func fromJSONString(_ string: String, detailLevel: Int) throws -> Self {
        throw SSModelError.notImplemented
    }
    
    
}
