//
//  ClubJoining.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/22.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class ClubJoining: NSManagedObject {
    
    func updateFromJson(json: JSON) {
        nickName = json["nick_name"].string
        showNickName = json["show_nick_name"].boolValue
        noDisturbing = json["no_disturbing"].boolValue
        alwaysOnTop = json["always_on_top"].boolValue
    }
}