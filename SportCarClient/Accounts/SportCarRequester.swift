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
    
    private let _urlMap: [String: String] = [
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
    
    func carList(scope: String, manufacturer: String? = nil, carName: String? = nil, filter: String? = nil, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        var param = ["scope": scope]
        switch scope {
        case "manufacturer":
            if let filter = filter where filter != "" {
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
        manufacturer: String,
        carName: String,
        subName: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback) -> Request {
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
        signature:String?,
        carId: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback) -> Request {
        return post(
            urlForName("follow", param: ["carID" :carId]), parameters: ["signature": signature ?? ""],
            responseDataField: "data",
            onSuccess: onSuccess, onError: onError
        )
    }
    
    func authenticateSportscar(carID: String, driveLicense: UIImage, photo: UIImage, idCard: UIImage, licenseNum: String, onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()) {
        upload(urlForName("auth"),
               parameters: ["car_id": carID, "drive_license": driveLicense, "photo": photo, "id_card": idCard, "license": licenseNum],
               onSuccess: onSuccess,
               onProgress: onProgress,
               onError: onError
        )
    }
    
    func deleteCar(carID: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(urlForName("delete", param: ["carID": carID]), onSuccess: onSuccess, onError: onError)
    }
    
    func updateCarSignature(carID: String, signature: String, onSuccess: SSSuccessCallback, onError: SSFailureCallback) -> Request {
        return post(urlForName("signature", param: ["carID": carID]),
                    parameters: ["signature": signature],
                    onSuccess: onSuccess, onError: onError)
    }
}

