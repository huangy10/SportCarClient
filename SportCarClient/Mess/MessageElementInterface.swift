//
//  MessageElementInterface.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation

protocol MessageElementInterface {
    func getSSID() -> Int32
    
    func getSSIDString() -> String
    
    func getCover() -> NSURL
    
    func getName() -> String
}
