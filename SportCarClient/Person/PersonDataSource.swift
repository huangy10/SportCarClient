//
//  PersonDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Dollar

class PersonDataSource {
    // 目标用户
    var user: User!
    // 拥有的跑车
    var cars: [SportCar] = []
    var selectedCar: SportCar?
    // 是否关注了此人
    var hasFollowed: Bool = false
    // 状态字典, 按照跑车组织的状态数据
    var statusDict: [String: [Status]] = [:]
    // 状态列表，顺序存储所有的状态
    var statusList: [Status] = []
    
    /**
     处理从服务器获取的用户信息json数据包，数据包中的内容是authed-cars的列表
     
     - parameter json: json数据包，已经剔除了success
     */
    func handleAuthedCarsJSONResponse(json: JSON, user: User = MainManager.sharedManager.hostUser!) {
        // 认证汽车的获取不存在分页获取的问题，故每次获取的json数据包含的都是所有的认证汽车，故此处需要将原有的数据删除
        cars.removeAll()
        let data = json.arrayValue
        for carJSON in data {
            // 重整一下数据结构钢
            let tempJSON = SportCar.reorgnaizeJSON(carJSON)
            let car = try! MainManager.sharedManager.getOrCreate(tempJSON, detailLevel: 1) as SportCar
            cars.append(car)
            if statusDict[car.ssidString] == nil {
                statusDict[car.ssidString] = []
            }
        }
    }
    
    /**
     处理statuslist的响应
     
     - parameter json: json数据
     - parameter car:  对应的car
     */
    func handleStatusListResponse(json: JSON, car: SportCar?) {
        let data = json.arrayValue
        var targetStatusList: [Status]
        if car == nil {
            targetStatusList = statusList
        }else {
            targetStatusList = statusDict[car!.ssidString]!
        }
        
        for statusJSON in data {
            let status = try! MainManager.sharedManager.getOrCreate(statusJSON) as Status
            if targetStatusList.filter({ $0.ssid == status.ssid }).count == 0 {
                targetStatusList.append(status)
            }
        }
        // Remove the redundant elements
        if car == nil {
            statusList = $.uniq(targetStatusList) { $0.ssid }
        } else {
            statusList = $.uniq(targetStatusList) { $0.ssid }
        }
    }
    
    func addCar(car: SportCar) {
        cars.append(car)
        if statusDict[car.ssidString] == nil {
            statusDict[car.ssidString] = []
        }
    }
    
    func deleteCar(car: SportCar) {
        self.cars = $.remove(self.cars, callback: { $0.ssid == car.ssid })
        statusDict.removeValueForKey(car.ssidString)
    }
    
    func newStatus(status: Status) {
        statusList.insert(status, atIndex: 0)
        if let car = status.car {
            if var list = self.statusDict[car.ssidString] {
                list.insert(status, atIndex: 0)
            } else {
                self.statusDict[car.ssidString] = [status]
            }
        }
    }
    
    func deleteStatus(status: Status) {
        //
        statusList.remove(status)
        if let car = status.car, var list = statusDict[car.ssidString] {
            list.remove(status)
        }
    }
}
