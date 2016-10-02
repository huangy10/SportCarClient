//
//  BaseModel.swift
//

import Foundation
import CoreData
import SwiftyJSON
import AlecrimCoreData

func ==<T: BaseModel>(obj1: T, obj2: T) -> Bool {
    return obj1.ssid == obj2.ssid
}

class BaseModel: NSManagedObject {
    
    class var idField: String {
        return "ssid"
    }
    
    var ssidString: String {
        return "\(ssid)"
    }
    
    weak var manager: MainManager! {
        didSet {
            managerDidSet()
        }
    }
    
    func managerDidSet() {
        // 留给子类实现
    }
    
    /**
     从json数据中载入Model需要的数据
     
     - parameter data: json数据
     - parameter ctx:  所属的context
     */
    @discardableResult
    func loadDataFromJSON(_ data: JSON, detailLevel: Int, forceMainThread: Bool = false) throws -> Self {
        if forceMainThread && !Thread.isMainThread {
            assertionFailure()
        }
        if ssid == 0 {
            ssid = data[type(of: self).idField].int32Value
            assert(ssid > 0, "Model can not be initalized without a id")
        }
        
        if let host = MainManager.sharedManager.hostUserID {
            hostSSID = host
        } else {
            hostSSID = 0
        }
        return self
    }
    
    @discardableResult
    func loadInitialFromJSON(_ data: JSON) throws -> Self {
        if let host = MainManager.sharedManager.hostUserID {
            hostSSID = host
        } else {
            hostSSID = 0
        }
        return self
    }
    
    /**
     将这个对象转化成为json字符串
     
     - parameter detailLevel: 这个数值决定了最后导出的字符串中信息的详细程度
     
     - returns: json字符串
     */
    
    @discardableResult
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
    
    @discardableResult
    func toJSONObject(_ detailLevel: Int) throws -> JSON {
        throw SSModelError.notImplemented
    }
    
    /**
     从json字符串中恢复对象数据
     
     - parameter string:      字符串内容
     - parameter detailLevel: 详细程度
     */
    @discardableResult
    func fromJSONString(_ string: String, detailLevel: Int) throws -> Self{
        let json = JSON(data: string.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        _ = try self.loadDataFromJSON(json, detailLevel: detailLevel)
        return self
    }
    
    @discardableResult
    func toContext(_ ctx: DataContext) -> BaseModel? {
        if self.managedObjectContext == ctx {
            return self
        }
        return ctx.object(with: self.objectID) as? BaseModel
    }
}

