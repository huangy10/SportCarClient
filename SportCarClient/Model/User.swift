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
    var ownedCars: [SportCar] = []
    
    // 下面是缓存的查询数据
    var avatarCar: SportCar?
    
    var hasAvatarCar: Bool {
        if avatarCar != nil {
            return true
        }
        return false
    }
    
    /// 最近发布的一条Status描述
    var recentStatusDes: String?
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
    
    func equal<T: Equatable>(fieldValue: T?, jsonValue: T?) -> Bool{
        if jsonValue == nil {
            return true
        } else{
            return fieldValue == jsonValue
        }
    }
    /**
     比较User中的数据和JSON指定的数据是否相等
     
     - parameter json:      json数据
     - parameter ignoreNil: 是否忽视json中nil的字段
     
     - returns: 是否相等
     */
    func isEqualTo(json: JSON, ignoreNil: Bool=false) -> Bool{
        if equal(avatarUrl, jsonValue: json["userID"].string) &&
        equal(district, jsonValue: json["district"].string) &&
        equal(gender, jsonValue: json["gender"].string) &&
        equal(nickName, jsonValue: json["nick_name"].string) &&
        equal(phoneNum, jsonValue: json["phone_num"].string) &&
        equal(starSign, jsonValue: json["star_sign"].string) &&
        equal(job, jsonValue: json["job"].string) &&
        equal(signature, jsonValue: json["signature"].string) &&
        equal(age, jsonValue: json["age"].int32){
            return true
        }
        return false
    }
    
    /**
     比较两个user是否是指代的同一个用户，只比对userID
     
     - parameter user: 待比较的用户
     
     - returns: 是否相等
     */
    func isEqualToSimple(user: User) -> Bool{
        return self.userID == user.userID
    }
    
    /**
     从json数据结构中载入数据，注意必须满足json["userID"] = self.userID赋值才会有效
     
     - parameter json: json数据
     - parameter forceUpdateNil: 是否强制赋值nil
     
     - returns: 赋值是否成功
     */
    func loadValueFromJSON(json: JSON, forceUpdateNil: Bool=false) -> Bool{
        
        if json["userID"] == nil || json["userID"].stringValue != self.userID{
            return false
        }
        if forceUpdateNil {
            avatarUrl = json["avatar"].string
            district = json["district"].string
            gender = json["gender"].string
            nickName = json["nick_name"].string
            phoneNum = json["phone_num"].string
            starSign = json["star_sign"].string
            job = json["job"].string
            signature = json["signature"].string
            age = json["age"].int32 ?? 0
            profile?.loadValueFromJSON(json, forceUpdateNil: true)
            return true
        }
        // 在内部定义了一个setter以减少后面的代码重复
        
        let setter = { (inout property: String?, jsonFieldName: String) in
            if let value = json[jsonFieldName].string {
                property = value
            }
        }
        setter(&avatarUrl, "avatar")
        setter(&district, "district")
        setter(&gender, "gender")
        setter(&nickName, "nick_name")
        setter(&phoneNum, "nickName")
        setter(&starSign, "star_sign")
        setter(&job, "job")
        setter(&signature, "signature")
        if let age = json["age"].int32 {
            self.age = age
        }
        profile?.loadValueFromJSON(json)
        return true
    }
    
    /// 用户的数据是否的完整，主要检查id，头像，昵称三个信息
    var isIntegrited: Bool {
        get{
            return userID != nil && nickName != nil && avatarUrl != nil
        }
    }
    
    /**
     超级详细的数据读取，其数据格式参照从服务器获取的profile info数据
     
     - parameter json: json数据
     */
    func loadValueFromJSONWithProfile(json: JSON) {
        nickName = json["nick_name"].string
        age = json["age"].int32Value
        avatarUrl = json["avatar"].string
        gender = json["gender"].string
        starSign = json["gender"].string
        district = json["district"].string
        job = json["job"].string
        signature = json["signature"].string
        let avatarCarJSON = json["avatar_car"]
        avatarCar = SportCarOwnerShip.objects.createOrLoadHostUserOwnedCar(avatarCarJSON)!.car
        let profile = self.profile
        profile?.avatarCarID = avatarCar?.carID
        profile?.avatarCarImage = avatarCar?.image
        profile?.avatarCarLogo = avatarCar?.logo
        profile?.avatarCarName = avatarCar?.name
        profile?.statusNum = json["status_num"].int32Value
        profile?.fansNum = json["fans_num"].int32Value
        profile?.followNum = json["follow_num"].int32Value
        let avatarClubJSON = json["avatarClub"]
        // Club和User是属于同一个context的
        let avatarClub = Club.objects.getOrCreate(avatarClubJSON)
        profile?.avatarClubID = avatarClub?.clubID
        profile?.avatarClubLogo = avatarClub?.logo_url
        profile?.avatarClubName = avatarClub?.name
    }

}





// MARK: - 这个扩展主要市打包了一些常用属性的获取，注意这里所有的函数只执行了获取操作
extension User {
    /* 
     写给将来的维护者：
     这个部分的功能，是为了简化一些常用的操作，和上面的用于支持全局数据一致性的函数的功能不同，这里的函数只载入目前已经存在于内存中和CoreData中的数据
    */
    
    
    /**
    获取该用户所有的认证车辆
    
    - returns: 打包了的结果
    */
    func getAllAuthenticatedCars() -> ManagerResult<[SportCar], ManagerError> {
        return ManagerResult.Success(self.ownedCars)
    }
}

// MARK: - 和News的关系
extension User {
    /**
     查看是否给定的news被该用户Like了，注意这里不会创建网络请求，只是查询已经在内存中的数据
     
     - parameter news: 指定的news
     
     - returns: BOOL
     */
    @nonobjc func isNewsLiked(news: News) -> Bool {
        return isNewsLiked(news.newsID!)
    }
    
    @nonobjc func isNewsLiked(newsID: String) -> Bool {
        return likeNews.contains({ (n: News) -> Bool in
            return newsID == n.newsID
        })
    }
}

