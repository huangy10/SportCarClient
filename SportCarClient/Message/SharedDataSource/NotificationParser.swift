//
//  NotificationParser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class NotificationParser: BaseParser {
    
    override func parse(data: JSON) throws -> Notification {
        let notification = try ChatModelManger.sharedManager.getOrCreate(data) as Notification
        return notification
    }
    
}

