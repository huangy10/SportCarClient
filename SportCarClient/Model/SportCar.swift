//
//  SportCar.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/17.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON

/*
 关于跑车数据设计的说明：
 相比于变化性大的用户数据，跑车数据的变化频率相当低，下面的设计部分是基于这一特点的。
*/

/// 跑车实例
class SportCar: NSManagedObject {
    
    static let objects = SportCarManager()
    
}

extension SportCar {
  
    func loadFromJSON(json: JSON, basic: Bool = true) {
        image = json["image"].string
        name = json["name"].string
        logo = json["logo"].string
        if !basic {
            price = json["price"].string
            engine = json["engine"].string
            transimission = json["trans"].string
            body = json["body"].string
            max_speed = json["speed"].string
            zeroTo60 = json["acce"].string
        }
    }
}

class SportCarManager: ModelManager {
    
    func getOrCreate(json: JSON, ctx: DataContext? = nil, basic: Bool = true) -> SportCar{
        let context = ctx ?? defaultContext
        let carID = json["carID"].stringValue
        assert(carID != "")
        let car = context.sportCars.firstOrCreated({$0.carID == carID})
        car.loadFromJSON(json, basic: true)
        return car
    }
}

// MARK: - 这个扩展解决的是ownership的问题
extension SportCarManager {
    
    /**
     获取或者创建一个空的
     
     - parameter initail: 传入的初始化值
     - parameter car: 跑车
     - parameter user: 用户
     
     - returns: 返回获取的结果，以及该结果是读取的还是创建的
     */
    func getOrCreateOwnership(car: SportCar, user: User, initail: JSON, ctx: DataContext? = nil) -> (SportCarOwnerShip, Bool){
        let context = ctx ?? defaultContext
        let userInCurrentContext = context.objectWithID(user.objectID) as! User
        // 首先检查这个ownership关系是否已经存在，如果已经存在，则直接返回即可
        let ownership = user.ownership
        for o in ownership {
            if o.user == user {
                return (o, false)
            }
        }
        // 如果没有发现则需要创建
        let newOwnership = context.sportCarOwnerShips.createEntity()
        newOwnership.user = userInCurrentContext
        newOwnership.car = car
        newOwnership.signature = initail["signature"].string
        newOwnership.identified = true
        user.ownedCars.append(newOwnership)
        do { 
            try context.save()
        }catch let err {
            print(err)
            assertionFailure()
        }
        return (newOwnership, true)
    }
}