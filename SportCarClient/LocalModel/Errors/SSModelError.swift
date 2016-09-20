//
//  SSModelError.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


enum SSModelError: Error {
    case notImplemented
    case invalidJSON
    case invalidJSONString
    case saveFailure
    case emptyID
    case integrityError
    case notSupported
    case unknown
}
