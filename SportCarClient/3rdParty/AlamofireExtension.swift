//
//  AlamofireExtension.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/7.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire


extension Request {
    func responseJSON(_ queue: DispatchQueue, completionHandler: (Response<AnyObject, NSError>) -> Void) -> Request {
        return self.response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: .allowFragments), completionHandler: completionHandler)
    }
}
