//
//  ChatParser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class ChatParser {
    
    func parse(data: JSON) throws -> (ChatRecord, RosterItem?) {
        let newRecrod = try ChatModelManger.sharedManager.getOrCreate(data) as ChatRecord
        let roster = data["roster"]
        if roster.exists() {
            let rosterItem = RosterManager.defaultManager.getOrCreateNewRoster(roster, autoBringToFront: true)
            rosterItem.updatedAt = newRecrod.createdAt
            return (newRecrod, rosterItem)
        }
        return (newRecrod, nil)
    }
}

