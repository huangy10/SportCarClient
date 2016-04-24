//
//  BaseParser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseParser {
    
    /**
     Implement this in the subclasses
     */
    func parse(data: JSON) throws -> BaseModel {
        throw SSModelError.NotImplemented
    }
    
}
