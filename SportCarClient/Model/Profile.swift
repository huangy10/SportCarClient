//
//  Profile.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/22.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


class Profile: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}


// MARK: - 处理从JSON初始化的问题
extension Profile {
    /**
     从JSON载入数据，注意这个函数里面并未检查一致性
     
     - parameter json: JSON
     */
    func loadValueFromJSON(json: JSON) {
        fansNum = json["fans_num"].int32 ?? 0
        followNum = json["follow_num"].int32 ?? 0
        statusNum = json["status_num"].int32 ?? 0

        let avatarCar = json["avatar_car"]
        avatarCarID = avatarCar["carID"].string
        avatarCarImage = avatarCar["image"].string
        avatarCarName = avatarCar["name"].string
        avatarCarLogo = avatarCar["logo"].string

        let avatarClub = json["avatar_club"]
        avatarClubID = avatarClub["id"].string
        avatarClubName = avatarClub["club_name"].string
        avatarClubLogo = avatarClub["club_logo"].string
    }
    
    func setAvatarCar(car: SportCar) {
        avatarCarID = car.carID
        avatarCarImage = car.image
        avatarCarName = car.name
        avatarCarLogo = car.logo
    }
    
    func setAvatarClub(club: Club) {
        avatarClubID = club.clubID
        avatarClubName = club.name
        avatarClubLogo = club.logo_url
    }
}
