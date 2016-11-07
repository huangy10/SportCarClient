//
//  PersonDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/7.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Dollar


protocol PersonDataSourceDelegate: class {
    var user: User { get set}
    var cars: [SportCar] { get set }
    var selectedCar: SportCar? { get set }
    
    func addCar(_ car: SportCar)
    func rmCar(_ car: SportCar)
    
    func getStatus(atIdx idx: Int) -> Status
    func numberOfStatus() -> Int
    func numberOfStatusCell() -> Int
    func updateStatusList(forCar car: SportCar?, withData data: [Status])
}


class DefaultPersonDataSource: PersonDataSourceDelegate {
    var user: User
    var cars: [SportCar] = []
    var selectedCar: SportCar?
    
    fileprivate var statusDict: [String: [Status]] = [:]
    
    init (user: User) {
        self.user = user
    }
    
    fileprivate func getMapKey(forCar car: SportCar?) -> String {
        if let car = car {
            return car.ssidString
        } else {
            return ""
        }
    }
    
    fileprivate func getStatusList(forCar car: SportCar?) -> [Status] {
        return statusDict[getMapKey(forCar: car)] ?? []
    }
    
    fileprivate func getStatusList() -> [Status] {
        return getStatusList(forCar: selectedCar)
    }
    
    func getStatus(atIdx idx: Int) -> Status {
        return getStatusList()[idx]
    }
    
    func numberOfStatus() -> Int {
        return getStatusList().count
    }
    
    func numberOfStatusCell() -> Int {
        let num = numberOfStatus()
        if user.isHost && selectedCar == nil {
            return num + 1
        } else {
            return num
        }
    }
    
    func updateStatusList(forCar car: SportCar?, withData data: [Status]) {
        var oldStatus = getStatusList(forCar: car)
        oldStatus.append(contentsOf: data)
        oldStatus = $.uniq(oldStatus, by: { $0.ssid })
        statusDict[getMapKey(forCar: car)] = oldStatus
    }
    
    func addCar(_ car: SportCar) {
        cars.append(car)
    }
    
    func rmCar(_ car: SportCar) {
        cars = $.remove(cars, callback: { $0.ssid == car.ssid })
        statusDict[getMapKey(forCar: car)] = nil
    }
}
