//
//  RequestProtocol.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire


protocol RequestProtocol: class {
    var rp_currentRequest: Request? { get }
    
    func rp_cancelRequest()
}

extension RequestProtocol {
    
    func rp_cancelRequest() {
        rp_currentRequest?.cancel()
    }
    
}