//
//  PersonDataSource2.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Dollar


class PersonDataSource2 {
    
    var user: User
    private var _cars: [SportCar] = []
    var cars: [SportCar] {
        return _cars
    }
    
    func reload(cars: [SportCar]) {
        _cars = cars
        if let car = selectedCar, !cars.contains(value: car) {
            selectedCar = nil
        }
    }
    
    private var _status = PersonStatusMatrix()
    var status: PersonStatusMatrix {
        return _status
    }
    
    var selectedCar: SportCar? = nil
    
    var currentFocusedStatus: [Status] {
       return _status[selectedCar?.ssidString]
    }
    
    var hasCarSelected: Bool {
        return selectedCar != nil
    }
    
    init (user: User) {
        self.user = user
    }
    
    @discardableResult
    func add(car: SportCar) -> Bool {
        if _cars.contains(value: car) {
            return false
        }
        _cars.insert(car, at: 0)
        return true
    }
    
    @discardableResult
    func remove(car: SportCar) -> Bool {
        if let _ = _cars.remove(value: car) {
            _status.clearStatus(forCar: car.ssidString)
            return true
        } else {
            return false
        }
    }
    
    func add(status: Status) {
        if let car = status.car {
            add(car: car)
            _status.addToHead(status)
        }
    }
    
    func remove(status: Status) {
        _status.remove(status)
    }
}

class PersonStatusMatrix {
    
    private var data: [Status] = []
    private var carRelatedStatus: [String: [Status]] = [:]
    
    init () {
        
    }
    
    var count: Int {
        return data.count
    }
    
    subscript(carSSID: String?) -> [Status] {
        if let key = carSSID {
            return carRelatedStatus[key] ?? []
        } else {
            return data
        }
    }
    
    func addToHead(_ status: Status) {
        data.insert(status, at: 0)
        if let carSSID = status.car?.ssidString {
            if let _ = carRelatedStatus[carSSID] {
                carRelatedStatus[carSSID]!.insert(status, at: 0)
            } else {
                carRelatedStatus[carSSID] = [status]
            }
        }
    }
    
    func append(_ status: Status) {
        data.append(status)
        if let carSSID = status.car?.ssidString {
            if let _ = carRelatedStatus[carSSID] {
                carRelatedStatus[carSSID]!.append(status)
            } else {
                carRelatedStatus[carSSID] = [status]
            }
        }
    }
    
    func remove(_ status: Status) {
        data = $.remove(data, callback: { $0 == status})
        if let carSSID = status.car?.ssidString {
            if let temp = carRelatedStatus[carSSID] {
                carRelatedStatus[carSSID] = $.remove(temp, value: status)
            }
        }
    }
    
    func clearStatus(forCar key: String) {
        data = $.remove(data, callback: { $0.car?.ssidString == key })
        carRelatedStatus[key] = nil
    }
    
    func statusCount(forCar key: String) -> Int {
        if let cache = carRelatedStatus[key] {
            return cache.count
        } else {
            return 0
        }
    }
}
