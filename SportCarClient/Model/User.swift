//
//  User.swift
//  SportCarClient
//
//  Created by 黄延 on 15/11/27.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON
import AlecrimCoreData // 使用第三方Wrapped的CoreData来简化这边的工作

class User: NSManagedObject {
    /// 仿照了Django的风格将Model的管理器设置为Model的类变量，但是角色并不相同，这里的objects的主要功能是提供
    static let objects = UserManager()
    
    /// 该用户拥有的跑车
    var ownedCars: [SportCarOwnerShip] = []
    
    /// 最近发布的一条Status描述
    var recentStatusDes: String?
    
    var followed: Bool = false
}

extension User{
    
    /**
     当创建用户时，自动为其创建Profile对象
     */
    override func awakeFromInsert() {
        if self.profile != nil {
            return
        }
        if let context = self.managedObjectContext as? DataContext {
            // 只在DataContext下擦执行这个创建操作
            profile = context.profiles.createEntity()
            profile?.user = self
        }
    }
}

// MARK: - 这个扩展增加了对JSON数据的支持
extension User{
    
    /**
     从json数据结构中载入数据，注意必须满足json["userID"] = self.userID赋值才会有效
     
     - parameter json: json数据
     - parameter forceUpdateNil: 是否强制赋值nil
     
     - returns: 赋值是否成功
     */
    func loadFromJSON(json: JSON, ctx: DataContext? = nil, basic: Bool = true) {
        nickName = json["nick_name"].string
        avatarUrl = json["avatar"].string
        if !basic {
            district = json["district"].string
            gender = json["gender"].string
            phoneNum = json["phone_num"].string
            starSign = json["star_sign"].string
            job = json["job"].string
            signature = json["signature"].string
            age = json["age"].int32 ?? 0
            profile?.loadValueFromJSON(json)
            if let f = json["followed"].bool {
                self.followed = f
            }
        }
    }
    
    func setAvatarCar(car: SportCar) {
        profile?.setAvatarCar(car)
    }
    
    func setAvatarClub(club: Club) {
        profile?.setAvatarClub(club)
    }
}

class UserManager: ModelManager {
    
    /// 当前登陆的用户
    private var _hostUser: User? {
        didSet {
            hostUserID = _hostUser?.userID
        }
    }
    func hostUser(ctx: DataContext? = nil) -> User? {
        if _hostUser == nil {
            return nil
        } else if ctx == nil || ctx == defaultContext {
            return _hostUser
        }
        let context = ctx ?? defaultContext
        return context.objectWithID(_hostUser!.objectID) as? User
    }
    var hostUserID: String?
}


// MARK: - 用户数据的提取和存储
extension UserManager {
    
    func getOrLoad(userID: String, ctx: DataContext? = nil) -> User? {
        let context = ctx ?? defaultContext
        let user = context.users.first { $0.userID == userID }
        return user
    }

    func getOrCreate(json: JSON, ctx: DataContext? = nil, basic: Bool = true) -> User{
        let context = ctx ?? defaultContext
        let userID = json["userID"].stringValue
        assert(userID != "")
        let user = context.users.firstOrCreated{$0.userID == userID}
        user.loadFromJSON(json, ctx: context, basic: basic)
        return user
    }
    
}

// MARK: - 这个部分主要实现对Host用户的管理
extension UserManager {
    
    /**
     登录host用户，其实就是设置host值
     
     - parameter userID: host用户的id
     
     - returns: Result
     */
    func login(userID: String, ctx: DataContext? = nil){
        let context = ctx ?? defaultContext
        defer {
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "host_user_id")
        }
        // 检查是否制定的id已经是当前的host，若是直接返回即可
        if userID == hostUser(ctx)?.userID {
            return
        }
        let user = context.users.firstOrCreated { $0.userID == userID }
        _hostUser = user
    }
    
    /**
     恢复上次登陆的状态
     
     - returns: 返回hostUser，若返回的是nil表明没有存储的上一次登陆状态
     */
    func resumeLoginStatus() -> User? {
        if let userID = NSUserDefaults.standardUserDefaults().stringForKey("host_user_id") {
            login(userID)
            return hostUser()
        }
        return nil
    }
    
    /**
     注销登陆，这个操作会将hostUser置为nil，并将NSUserDefaults中存储的host_user_id移除
     */
    func logout() -> Void{
        if _hostUser == nil {
            return
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey("host_user_id")
        _hostUser = nil
    }
}

