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

class RadarRequester: BasicRequester {
    
    static let sharedInstance = RadarRequester()
    
    fileprivate let _urlMap: [String: String] = [
        "update": "update",
        "nearby": "nearby",
        "track": "<userID>/track"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "radar"
    }
    
    @available(*, deprecated: 1)
    func updateCurrentLocation(
        _ loc: CLLocationCoordinate2D,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) -> Request {
        return post(
            urlForName("update"),
            parameters: ["lat": loc.latitude, "lon": loc.longitude],
            responseDataField: "",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func getRadarDataWithFilter(
        _ loc: CLLocationCoordinate2D,
        scanCenter: CLLocationCoordinate2D,
        filterDistance: Double,
        filterType: String,
        filterParam: [String: AnyObject]?,
        onSuccess: (_ json: JSON?)->(),
        onError: (_ code: String?)->()
        ) -> Request {
        var params: [String: AnyObject] = [
            "filter": filterType,
            "loc": ["lat": loc.latitude, "lon": loc.longitude],
            "scan_center": ["lat": scanCenter.latitude, "lon": scanCenter.longitude],
            "scan_distance": filterDistance
        ]
        if let filterParam = filterParam {
            params["filter_param"] = filterParam
        }
        return post(
            urlForName("nearby"),
            parameters: params,
            encoding: .json,
               responseDataField: "result",
               onSuccess: onSuccess, onError: onError
        )
    }
    
    func getRadarData(
        _ loc: CLLocationCoordinate2D,
        scanCenter: CLLocationCoordinate2D,
        filterDistance: Double,
        onSuccess: (_ json: JSON?)->(),
        onError: (_ code: String?)->()
        ) -> Request{
        return post(
            urlForName("nearby"),
            parameters: [
                "filter": "distance", "filter_param": filterDistance,
                "loc": ["lat": loc.latitude, "lon": loc.longitude],
                "scan_center": ["lat": scanCenter.latitude, "lon": scanCenter.longitude]
            ], encoding: .json,
            responseDataField: "result",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func trackUser(_ userID: String, onSuccess: (_ json: JSON?)->(), onError: (_ code: String?)->()) -> Request {
        return get(urlForName("track", param: ["userID": userID]),
                   responseDataField: "location",
                   onSuccess: onSuccess, onError: onError)
    }
}
//
//
//class RadarURLMaker: AccountURLMaker {
//    static let sharedMaker = RadarURLMaker(user: nil)
//    
//    func updateLocation() -> String{
//        return website + "/radar/update"
//    }
//    
//    func updateRadarData() -> String {
//        return website + "/radar/nearby"
//    }
//    
//    func trackUser(userID: String) -> String {
//        return website + "/radar/\(userID)/track"
//    }
//}
//
//class RadarRequester: AccountRequester {
//    
//    static let requester = RadarRequester()
//    
//    /**
//     向服务器提交位置数据
//     
//     - parameter loc:               用户当前的位置
//     - parameter onSuccess: 成功以后调用的closure
//     - parameter onError:   失败以后调用的closure
//     */
//    func updateCurrentLocation(loc: CLLocationCoordinate2D, onSuccess: (json: JSON?)->(), onError: (code: String?)->()){
//        let url = RadarURLMaker.sharedMaker.updateLocation()
//        manager.request(.POST, url, parameters: ["lat": loc.latitude, "lon": loc.longitude]).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取附近的用户的数据
//     
//     - parameter loc:            用户当前的位置
//     - scanCenter loc:           用户观察的扫描中心
//     - parameter filterDistance: 距离筛选条件
//     - parameter onSuccess:      成功以后调用的closure
//     - parameter onError:        失败以后调用的closure
//     */
//    func getRadarData(loc: CLLocationCoordinate2D, scanCenter: CLLocationCoordinate2D, filterDistance: Double, onSuccess: (json: JSON?)->(), onError: (code: String?)->()) -> Request{
//        let url = RadarURLMaker.sharedMaker.updateRadarData()
//        return manager.request(
//            .POST, url, parameters: [
//                "filter": "distance", "filter_param": filterDistance,
//                "loc": ["lat": loc.latitude, "lon": loc.longitude],
//                "scan_center": ["lat": scanCenter.latitude, "lon": scanCenter.longitude]],
//            encoding: .JSON).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "result", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    func trackUser(userID: String, onSuccess: (json: JSON?)->(), onError: (code: String?)->()) -> Request {
//        let url = RadarURLMaker.sharedMaker.trackUser(userID)
//        return manager.request(.GET, url).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "location", onSuccess: onSuccess, onError: onError)
//        }
//    }
//}
