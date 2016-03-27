//
//  SSModelError.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


enum SSModelError: ErrorType {
    case NotImplemented
    case InvalidJSON
    case InvalidJSONString
    case SaveFailure
    case EmptyID
    case IntegrityError
    case NotSupported
    case Unknown
}