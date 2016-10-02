//
//  MainManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AlecrimCoreData
import CoreData
import SwiftyJSON


class MainManager {
    
    fileprivate static let _sharedMainManager = MainManager()
    
    class var sharedManager: MainManager {
        return _sharedMainManager
    }
    
    internal var mainContext: DataContext
    
    internal var _hostUser: User?
    internal var _hostUserID: Int32?
    
    internal var _workQueue: DispatchQueue?
    
    var workQueue: DispatchQueue {
        if _workQueue == nil {
            _workQueue = DispatchQueue.main
        }
        return _workQueue!
    }
    
    var hostUser: User? {
        if _hostUser == nil {
            return nil
        }
        if _hostUser?.managedObjectContext != getOperationContext() {
            _hostUser = _hostUser?.toContext(getOperationContext()) as? User
        }
        return _hostUser
    }
    
    var hostUserID: Int32? {
        return _hostUserID
    }
    
    var hostUserIDString: String? {
        if _hostUserID == nil {
            return nil
        }
        return "\(hostUserID!)"
    }
    
    var jwtToken: String!
    
    init () {
        mainContext = DataContext()
    }
    
    /**
     获取操作需要的context
     
     - returns: AlecrimCoreData库的DataContext类型
     */
    func getOperationContext() -> DataContext {
        return mainContext
    }
    
    func getOrCreate<T>(_ data: JSON, detailLevel: Int = 0, ctx: DataContext? = nil, overwrite: Bool = true) throws -> T where T : BaseModel {
        let context = ctx ?? getOperationContext()
        let table = AlecrimCoreData.Table<T>(dataContext: context)
        let id = data[T.idField].int32Value
        if T.isKind(of: User.self) && id == hostUserID {
            let obj = hostUser!
            if !overwrite {
                return obj as! T
            }
            return try obj.loadDataFromJSON(data, detailLevel: detailLevel) as! T
        }
        var created: Bool = false
        let obj = table.first({$0.ssid == id && $0.hostSSID == hostUserID}) ?? {
            let obj = table.createEntity()
            obj.ssid = id
            obj.manager = self
            created = true
            return obj
        }()
        obj.manager = self
        if overwrite || created {
            _ = try obj.loadDataFromJSON(data, detailLevel: detailLevel)
        }
        return obj
    }
    
    func createNew<T: BaseModel>(_ initial: JSON? = nil, ctx: DataContext? = nil) throws -> T {
        let context = ctx ?? getOperationContext()
        let table = AlecrimCoreData.Table<T>(dataContext: context)
        let newObj = table.createEntity()
        if initial != nil {
            _ = try newObj.loadInitialFromJSON(initial!)
        }
        newObj.manager = self
        newObj.hostSSID = MainManager.sharedManager.hostUserID!
        return newObj
    }
    
    func objectWithSSID<T: BaseModel>(_ ssid: Int32?, ctx: DataContext? = nil) -> T? {
        if ssid == nil {
            return nil
        }
        let context = ctx ?? getOperationContext()
        let table = AlecrimCoreData.Table<T>(dataContext: context)
        let obj = table.first({ $0.ssid == ssid && $0.hostSSID == hostUserID})
        obj?.manager = self
        return obj
    }
    
    func save() throws {
//        assert(!NSThread.isMainThread(), "Do not save context on main thread")
        try mainContext.save()
    }
    
    func login(_ user: User, jwtToken: String) {
        if _hostUser != nil || user.managedObjectContext != getOperationContext() {
            assertionFailure()
        }
        UserDefaults.standard.set(user.ssidString, forKey: "host_user_id")
        UserDefaults.standard.set(jwtToken, forKey: "\(user.ssidString)_jwt_token")
        _hostUser = user
        _hostUserID = user.ssid
        self.jwtToken = jwtToken
        try! MainManager.sharedManager.save()
        
        // Initialize the message system
        MessageManager.defaultManager.connect()
        PermissionCheck.sharedInstance.sync()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "host_user_id")
        _hostUser = nil
        _hostUserID = nil
        MessageManager.defaultManager.disconnect()
    }
    
    func resumeLoginStatus() -> MainManager {
        if let userIDString = UserDefaults.standard.string(forKey: "host_user_id") {
            guard let jwtToken = UserDefaults.standard.string(forKey: "\(userIDString)_jwt_token") else {
                return self
            }
            self.jwtToken = jwtToken
            let userID = Int32(userIDString)
            if let user: User = AlecrimCoreData.Table<User>(dataContext: getOperationContext()).first({$0.ssid  == userID }) {
                user.manager = self
                login(user, jwtToken: jwtToken)
            }
        }
        return self
    }
}
