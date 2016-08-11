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
    func loadDataFromJSON(data: JSON, detailLevel: Int, forceMainThread: Bool = false) throws -> Self {
        if forceMainThread && !NSThread.isMainThread() {
            assertionFailure()
        }
        if ssid == 0 {
            ssid = data[self.dynamicType.idField].int32Value
            print(self.dynamicType.idField)
            assert(ssid > 0, "Model can not be initalized without a id")
        }
        
        if let host = MainManager.sharedManager.hostUserID {
            hostSSID = host
        } else {
            hostSSID = 0
        }
        return self
    }
    
    func loadInitialFromJSON(data: JSON) throws -> Self {
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
    func toJSONString(detailLevel: Int) throws -> String {
        let json = try toJSONObject(detailLevel)
        if json.isEmpty {
            throw SSModelError.Unknown
        }
        if let result = json.rawString() {
            return result
        } else {
            throw SSModelError.Unknown
        }
    }
    
    func toJSONObject(detailLevel: Int) throws -> JSON {
        throw SSModelError.NotImplemented
    }
    
    /**
     从json字符串中恢复对象数据
     
     - parameter string:      字符串内容
     - parameter detailLevel: 详细程度
     */
    func fromJSONString(string: String, detailLevel: Int) throws -> Self{
        let json = JSON(data: string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        try self.loadDataFromJSON(json, detailLevel: detailLevel)
        return self
    }
    
//    private func toContextHelper<T: BaseModel>(ctx: DataContext) -> T? {
//        let obj = ctx.objectWithID(self.objectID)
//        print(T.description())
//        print(self.dynamicType)
//        print(obj)
//        return ctx.objectWithID(self.objectID) as! T
//    }
    
    func toContext(ctx: DataContext) -> BaseModel? {
        if self.managedObjectContext == ctx {
            return self
        }
        return ctx.objectWithID(self.objectID) as? BaseModel
    }
}

