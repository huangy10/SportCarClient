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
    func responseJSON(queue: dispatch_queue_t, completionHandler: Response<AnyObject, NSError> -> Void) -> Request {
        return self.response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments), completionHandler: completionHandler)
    }
}