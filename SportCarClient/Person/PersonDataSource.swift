//
//  PersonDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON

class PersonDataSource {
    // 目标用户
    var user: User!
    // 拥有的跑车
    var owns: [SportCarOwnerShip] = []
    var selectedCar: SportCarOwnerShip?
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
    func handleAuthedCarsJSONResponse(json: JSON, user: User = User.objects.hostUser()!) {
        // 认证汽车的获取不存在分页获取的问题，故每次获取的json数据包含的都是所有的认证汽车，故此处需要将原有的数据删除
        owns.removeAll()
        let data = json.arrayValue
        for carJSON in data {
            let own = SportCarOwnerShip.objects.createOrLoadOwnedCars(carJSON, owner: user)
            owns.append(own!)
            if statusDict[own!.car!.carID!] == nil {
                statusDict[own!.car!.carID!] = []
            }
            print(own?.car?.carID)
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
            targetStatusList = statusDict[car!.carID!]!
        }
        
        for statusJSON in data {
            let status = Status.objects.getOrCreate(statusJSON)
            targetStatusList.append(status)
        }
    }
}