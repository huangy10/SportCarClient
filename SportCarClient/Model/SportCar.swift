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
    func loadFromJSON(json: JSON) {
        
    }
    
    func loadFromData(data: [String: AnyObject?]) {
        
    }
}

class SportCarManager {
    
    /// 存储当前内存池类的所有跑车数据
    var cars = [String: SportCar]()
    /// 主线程的context
    let context: DataContext
    /// Background下运行的context，用来处理大批量操作
    let privateContext: DataContext
    init() {
        context = DataContext()
        privateContext = DataContext(parentDataContext: context)
    }
}

// MARK: - 这个extension处理跑车的内存池存取
extension SportCarManager {
    /* 这个扩展主要处理当前用户的数据的同步问题
    */
    func returnError<Value>(err: ManagerError) -> ManagerResult<Value, ManagerError>{
        return ManagerResult.Failure(err)
    }
    /**
     利用服务器返回的json字典创建一个跑车对象
     
     - parameter json: json字典
     
     - returns: 返回的是用ManagerResult打包的数据
     */
    func create(json: JSON) -> ManagerResult<SportCar, ManagerError> {
        guard let carID = json["carID"].string else{
            return returnError(.KeyError)
        }
        if let car = cars["carID"] {
            // 只要有id吻合，默认就是同一个车辆
            return ManagerResult.Success(car)
        }
        // 没有在内存池里面找到需要的车辆，则创建一个新的条目
        let car = context.sportCars.firstOrCreated {$0.carID == carID}
        car.loadFromJSON(json)
        do {
            try context.save()
        }catch let err{
            print("\(err)")
            return returnError(.CantSave)
        }
        return ManagerResult.Success(car)
    }
    
    /**
     和上面的类似，但是接收的是字典
     
     - parameter data: 输入数据
     
     - returns: 返回的是用ManagerResult打包的数据
     */
    func create(data: [String: AnyObject?]) -> ManagerResult<SportCar, ManagerError> {
        guard let carID = data["carID"] as? String else{
            return returnError(.KeyError)
        }
        if let car = cars["carID"] {
            // 只要有id吻合，默认就是同一个车辆
            return ManagerResult.Success(car)
        }
        // 没有在内存池里面找到需要的车辆，则创建一个新的条目
        let car = context.sportCars.firstOrCreated {$0.carID == carID}
        car.loadFromData(data)
        do {
            try context.save()
        }catch let err{
            print("\(err)")
            return returnError(.CantSave)
        }
        return ManagerResult.Success(car)
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
    func getOrCreateOwnership(car: SportCar, user: User, initail: JSON) -> (SportCarOwnerShip, Bool){
        // 首先检查这个ownership关系是否已经存在，如果已经存在，则直接返回即可
        let ownership = user.ownership
        for o in ownership {
            if o.user == user {
                return (o, false)
            }
        }
        // 如果没有发现则需要创建
        let newOwnership = context.sportCarOwnerShips.createEntity()
        newOwnership.user = user
        newOwnership.car = car
        user.ownedCars.append(car)
        do {
            try context.save()
        }catch let err {
            print(err)
            assertionFailure()
        }
        return (newOwnership, true)
    }
}