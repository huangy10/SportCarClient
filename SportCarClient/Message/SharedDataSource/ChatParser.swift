//
//  ChatParser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class ChatParser: BaseParser {
    
    override func parse(data: JSON) throws -> ChatRecord {
        let newRecrod = try ChatModelManger.sharedManager.getOrCreate(data) as ChatRecord
        return newRecrod
    }
    
}

