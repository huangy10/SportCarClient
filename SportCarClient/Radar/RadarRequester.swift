//
//  RadarRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/24.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import Alamofire


class RadarURLMaker: AccountURLMaker {
    static let sharedMaker = RadarURLMaker(user: nil)
    
    func updateLocation() -> String{
        return website + "/radar/update"
    }
    
    func updateRadarData() -> String {
        return website + "/radar/nearby"
    }
}

class RadarRequester: AccountRequester {
    
    static let requester = RadarRequester()
    
    /**
     向服务器提交位置数据
     
     - parameter loc:               用户当前的位置
     - parameter onSuccess: 成功以后调用的closure
     - parameter onError:   失败以后调用的closure
     */
    func updateCurrentLocation(loc: CLLocationCoordinate2D, onSuccess: (json: JSON?)->(), onError: (code: String?)->()){
        let url = RadarURLMaker.sharedMaker.updateLocation()
        manager.request(.POST, url, parameters: ["lat": loc.latitude, "lon": loc.longitude]).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
        }
    }
    
    /**
     获取附近的用户的数据
     
     - parameter loc:            用户当前的位置
     - parameter filterDistance: 距离筛选条件
     - parameter onSuccess:      成功以后调用的closure
     - parameter onError:        失败以后调用的closure
     */
    func getRadarData(loc: CLLocationCoordinate2D, filterDistance: Double, onSuccess: (json: JSON?)->(), onError: (code: String?)->()) {
        let url = RadarURLMaker.sharedMaker.updateRadarData()
        manager.request(.POST, url, parameters: ["filter": "distance", "filter_param": filterDistance, "loc": ["lat": loc.latitude, "lon": loc.longitude]], encoding: .JSON).responseJSON { (response) -> Void in
            self.resultValueHandler(response.result, dataFieldName: "result", onSuccess: onSuccess, onError: onError)
        }
    }
}