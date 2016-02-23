//
//  UserUtilities.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/24.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import AlecrimCoreData

// TODO: 整理和同一Model中所有模块的接口的形式

/**
 重载了等于判断的操作符
 
 - parameter left:
 - parameter right:
 
 - returns:
 */
func ==(left: User, right: User) -> Bool {
    return left.isEqualToSimple(right)
}

/// 这个类用来管理全部的类变量，做数据持久化工作
class UserManager {
    /*
    进一步说明设计思路：
    App的Model层需要解决以下两个关键的问题：
    1、数据的一致性。例如，当一个用户的数据更新时，App所有相关的用户数据需要被同步更新
    2、数据的持久性。即在app离线时要能够提供缓存的用户数据
    */
    /// 主线程上的context
    var context: DataContext
    /// 本Manager维持的Context
    var privateContext: DataContext
    /// 存储当前全局所有用户信息的字典，键值是userID
    var users = [String: User]()
    /// 上次访问的时间，这个时间是相对于整个Manager而言，并非单条数据的
    var lastAccess: NSDate?
    /// 上次修改的时间，同上针对Manager层面而言
    var lastModify: NSDate?
    /// 成员的最大寿命，秒
    var maxLife: Int?
    /// 访问次数：当访问次数超过达到100时，会将更改同步到CoreData数据库
    var accessTimes: Int = 0 {
        didSet{
            //
        }
    }
    /// 当前登陆的用户
    var hostUser: User?
    
    init(maxLife: Int?=60) {
        self.maxLife = maxLife
        lastAccess = NSDate()
        lastModify = NSDate()
        // 创建一个主线程的Context
        context = DataContext()
        // 创建一个Background线程的context以供数据的批量操作
        privateContext = DataContext(parentDataContext: context)
    }
    
    func onUserUpdate() {
        
    }
    
    func saveAll() -> Bool{
        do {
            try context.save()
            return true
        } catch _ {
            return false
        }
    }
}


// MARK: - 用户数据的提取和存储
extension UserManager {
    /* 这个扩展主要处理当前用户的数据的同步问题
    */
    func returnError<Value>(err: ManagerError) -> ManagerResult<Value, ManagerError>{
        return ManagerResult.Failure(err)
    }
    
    /**
     获取或者同从coredata中载入用户
     
     - parameter userID: 给定的用户id
     */
    func getOrReload(userID: String) -> User? {
        if let user = users[userID] {
            return user
        }else {
            let user = context.users.first { $0.userID == userID }
            return user
        }
    }
    /**
     利用从服务器返回的数据创建一个User对象，单个查询和写入直接在主线程上进行。如果创建的用户对象和已有的用户数据发生重叠，则将Manager中的对应数据覆盖
     
     - parameter json: JSON数据
     
     - returns: ManageResult
     */
    func create(json: JSON) -> ManagerResult<User, ManagerError>{
        let userID = json["userID"].stringValue
        if let user = users[userID] {
            user.loadValueFromJSON(json)
            do{
                try context.save()
            }catch let err {
                print(err)
                return returnError(.CantSave)
            }
            return ManagerResult.Success(user)
        }
        let user = context.users.firstOrCreated { $0.userID == userID }
        user.loadValueFromJSON(json)
        users["userID"] = user
        do{
            try context.save()
        }catch let err {
            print(err)
            return returnError(.CantSave)
        }
        return ManagerResult.Success(user)
    }
    
    /**
     利用从服务器返回的数据来创建一个User对象，涉及的数据较为全面,基本结构和上面的create(json: JSON)是类似的
     
     - parameter detailjson: 详细的json数据
     
     - returns: 生成的用户
     */
    func create(detailjson: JSON) -> User? {
        let userID = detailjson["userID"].stringValue
        if userID == "" {
            // 没有找到有效的userID
            return nil
        }
        if let user = users[userID] {
            user.loadValueFromJSONWithProfile(detailjson)
            return user
        }
        let user = context.users.firstOrCreated{ $0.userID == userID }
        user.loadValueFromJSONWithProfile(detailjson)
        // 将用户数据放进内存池中
        users[userID] = user
        return user
    }
    
    /**
     一次性存入大量数据，在background线程中进行。即便存储失败也会返回生成的数据
     
     - parameter jsons: JSON字典
     
     - returns: Wrapped User Array
     */
    func create(jsons: [JSON]) -> ManagerResult<[User], ManagerError>{
        var idList = [String]()
        for json in jsons {
            // 首先循环检查所有的JSON字典是否有必须的userID字段，且没有重复
            guard let userID = json["userID"].string else{
                return returnError(.KeyError)
            }
            if idList.contains(userID){
                return returnError(.Integrity)
            }
            idList.append(json["userID"].stringValue)
        }
        var newUsers = [User]()
        for json in jsons {
            let userID = json["userID"].stringValue
            if let user = users[userID] where user.isEqualTo(json){
                // 检查用户是否在现在的内存池中
                newUsers.append(user)
                accessTimes += 1
            }
            let user = context.users.firstOrCreated{$0.userID == userID}
            user.userID = userID
            user.loadValueFromJSON(json, forceUpdateNil: true)
            accessTimes += 1
            newUsers.append(user)
            users[userID] = user
        }
        do {
            try context.save()
        }catch {
            return returnError(.CantSave)
        }
        return ManagerResult.Success(newUsers)
    }
    
    /**
     重新载入指定id的用户，当这个id并不存在于core data数据库中时，返回NotFound错误
     
     - parameter userID: 指定的用户id
     
     - returns: 打包的返回结果
     */
    func reload(userID: String) -> ManagerResult<User, ManagerError>{
        if let user = users[userID] {
            return ManagerResult.Success(user)
        }
        if let user = context.users.first({ $0.userID == userID }) {
            return ManagerResult.Success(user)
        }
        return returnError(.NotFound)
    }
    
    func reload(usersID: [String]) -> ManagerResult<[User], ManagerError> {
        var remainUsers = [String]()
        var newUsers = [User]()
        // 首先载入所有已经在内存中的用户的数据
        for userID in usersID {
            if let user = users[userID] {
                newUsers.append(user)
            }else {
                remainUsers.append(userID)
            }
        }
        // 剩余的未在内存中的，从CoreData中查询出来
        let anotherUsers = context.users.filter { $0.userID.isIn(remainUsers) }
        for user in anotherUsers {
            self.users[user.userID!] = user
            newUsers.append(user)
        }
        return ManagerResult.Success(newUsers)
    }
}

// MARK: - 这个部分主要实现对Host用户的管理
extension UserManager {
    
    /**
     登录host用户，其实就是设置host值
     
     - parameter userID: host用户的id
     
     - returns: Result
     */
    func login(userID: String) -> ManagerResult<User, ManagerError> {
        defer {
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "host_user_id")
        }
        // 检查是否制定的id已经是当前的host，若是直接返回即可
        if userID == hostUser?.userID {
            return ManagerResult.Success(hostUser!)
        }
        // 检查是否已经在内存池中
        if let user = users[userID] {
            hostUser = user
            return ManagerResult.Success(user)
        }
        // 若无则从CoreData中获取
        let user = context.users.firstOrCreated { $0.userID == userID }
        hostUser = user
        // 注意要host用户也要加入users
        users[userID] = user
        do {
            try context.save()
        }catch _ {
            
        }
        return ManagerResult.Success(user)
    }
    
    /**
     恢复上次登陆的状态
     
     - returns: 返回hostUser，若返回的是nil表明没有存储的上一次登陆状态
     */
    func resumeLoginStatus() -> User? {
        if let userID = NSUserDefaults.standardUserDefaults().stringForKey("host_user_id") {
            let result = login(userID)
            switch result {
            case .Success(let user):
                return user
            case .Failure(_):
                return nil
            }
        }
        return nil
    }
    
    /**
     注销登陆，这个操作会将hostUser置为nil，并将NSUserDefaults中存储的host_user_id移除
     */
    func logout() -> Void{
        if hostUser == nil {
            return
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey("host_user_id")
        hostUser = nil
    }
    
    /**
     判断一个给定的user对象是否是host用户
     
     - parameter user: 给定的用户
     
     - returns: 是否是host用户
     */
    func isHostUser(user: User?) -> Bool {
        if user == nil || self.hostUser == nil{
            return false
        }
        if user!.userID == self.hostUser?.userID {
            return true
        }
        return false
    }
    
    func save() -> Bool{
        do {
            try context.save()
            return true
        }catch _ {
            return false
        }
    }
}