//
//  RosterModelInterface.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation

enum RosterItemType {
    case USER(User)
    case CLUB(Club)
}

class RosterModelInterface {
    /// The binded data, user or club
    var data: RosterItemType!
    /// Most recent message sent
    var recentChatDes: String!
    
    var unreadNum: Int = 0
}
