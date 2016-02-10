//
//  PersonDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


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
}
