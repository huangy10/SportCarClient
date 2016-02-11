//
//  SportCarOwnerShip.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/17.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import AlecrimCoreData
import SwiftyJSON


class SportCarOwnerShip: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static let objects = SportCarOwnerShipManager()
    
    func loadValueFromJSON(json: JSON, forceUpdateNil: Bool = false) {
        if forceUpdateNil {
            identified = json["identified"].bool ?? true
            signature = json["signature"].string
            if car != nil {
                car?.loadFromJSON(json["car"], forceUpdateNil: true)
            }else {
                car = SportCar.objects.create(json["car"]).value
            }
            return
        }
        if let identified = json["identified"].bool {
            self.identified = identified
        }
        if let signature = json["signature"].string {
            self.signature = signature
        }
        if car != nil {
            car?.loadFromJSON(json["car"])
        }else{
            car = SportCar.objects.create(json["car"]).value
        }
    }
}

class SportCarOwnerShipManager {
    
    let context = SportCar.objects.context
    
    /**
     创建或者载入由当前用户所拥有的跑车Ownership数据，注意这里的json数据是对应的sportcar的json数据，没有包含ownership的信息
     
     - parameter json: 跑车相关的数据
     
     - returns: ownership对象
     */
    func createOrLoadHostUserOwnedCar(json: JSON) -> SportCarOwnerShip?{
        let carID = json["carID"].stringValue
        let user = User.objects.hostUser!
        if let own = context.sportCarOwnerShips.first ({ $0.car.carID == carID && $0.user.userID == user.userID }) {
            own.car?.loadFromJSON(json)
            return own
        }else {
            let own = context.sportCarOwnerShips.createEntity() 
            let currentContextUser = context.objectWithID(user.objectID) as! User
            own.identified = true
            own.user = currentContextUser
            let car = SportCar.objects.create(json).value
            own.car = car
            
            return own
        }
    }
    
    func createOrLoadOwnedCars(json: JSON, owner: User) -> SportCarOwnerShip?{
        /// 注意：这里传入的json是描述的carJSON的数据
        let carID = json["car"]["carID"].stringValue
        if let own = context.sportCarOwnerShips.first ({ $0.car.carID == carID && $0.user.userID == owner.userID }) {
            own.loadValueFromJSON(json)
            return own
        }else {
            let own = context.sportCarOwnerShips.createEntity()
            let currentContextUser = context.objectWithID(owner.objectID) as! User
            own.identified = true
            own.user = currentContextUser
            own.loadValueFromJSON(json)
            return own
        }
    }
    
    func save() -> ErrorType?{
        do {
            try context.save()
            return nil
        }catch let error {
            return error
        }
    }
    
}
