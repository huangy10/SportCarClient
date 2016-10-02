//
//  SportCarRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class SportCarRequester: BasicRequester {
    
    static let sharedInstance = SportCarRequester()
    
    fileprivate let _urlMap: [String: String] = [
        "query_car": "querybyname",
        "follow": "<carID>/follow",
        "auth": "auth",
        "delete": "<carID>/delete",
        "signature": "<carID>/signature",
        "cars": "type_list"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "cars"
    }
    
    func carList(_ scope: String, manufacturer: String? = nil, carName: String? = nil, filter: String? = nil, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        var param = ["scope": scope]
        switch scope {
        case "manufacturer":
            if let filter = filter , filter != "" {
                param["filter"] = filter
            }
        case "car_name":
            param["manufacturer"] = manufacturer!
        case "sub_name":
            param["manufacturer"] = manufacturer!
            param["car_name"] = carName!
        default:
            assertionFailure()
        }
        return get(urlForName("cars"), parameters: param, responseDataField: "data", onSuccess: onSuccess, onError: onError)
    }
    
    func querySportCarWith(
        _ manufacturer: String,
        carName: String,
        subName: String,
        onSuccess: @escaping SSSuccessCallback,
        onError: @escaping SSFailureCallback) -> Request {
        return get(
            urlForName("query_car"),
            parameters: [
                "manufacturer": manufacturer,
                "car_name": carName,
                "sub_name": subName
            ],
            responseDataField: "data",
            onSuccess: onSuccess,
            onError: onError
        )
    }
    
    func postToFollow(
        _ signature:String?,
        carId: String,
        onSuccess: @escaping SSSuccessCallback,
        onError: @escaping SSFailureCallback) -> Request {
        return post(
            urlForName("follow", param: ["carID" :carId]), parameters: ["signature": signature ?? ""],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func authenticateSportscar(_ carID: String, driveLicense: UIImage, photo: UIImage, idCard: UIImage, licenseNum: String, onSuccess: @escaping (JSON?)->(), onProgress: @escaping (_ progress: Float)->(), onError: @escaping (_ code: String?)->()) {
        upload(urlForName("auth"),
               parameters: ["car_id": carID, "drive_license": driveLicense, "photo": photo, "id_card": idCard, "license": licenseNum],
               onSuccess: onSuccess,
               onProgress: onProgress,
               onError: onError
        )
    }
    
    func deleteCar(_ carID: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(urlForName("delete", param: ["carID": carID]), onSuccess: onSuccess, onError: onError)
    }
    
    func updateCarSignature(_ carID: String, signature: String, onSuccess: @escaping SSSuccessCallback, onError: @escaping SSFailureCallback) -> Request {
        return post(urlForName("signature", param: ["carID": carID]),
                    parameters: ["signature": signature],
                    onSuccess: onSuccess, onError: onError)
    }
}

