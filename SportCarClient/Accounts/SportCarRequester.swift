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
        "signature": "<carID>/signature"
    ]
    
    override var urlMap: [String : String] {
        return _urlMap
    }
    
    override var namespace: String {
        return "cars"
    }
    
    func querySportCarWith(
        manufacturer: String,
        carName: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback) -> Request {
        return get(
            urlForName("query_car"),
            parameters: [
                "manufacturer": manufacturer,
                "car_name": carName],
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
               parameters: ["car_id": carID, "driver_license": driveLicense, "photo": photo, "id_card": idCard, "license": licenseNum],
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
//
//
//class SportCarURLMaker: AccountURLMaker {
//    static let sharedMaker = SportCarURLMaker(user: nil)
//    
//    func querySportCar()->String{
//        return website + "/cars/querybyname"
//    }
//    
//    func followSportCar(carID: String) -> String {
//        return website + "/cars/\(carID)/follow"
//    }
//    
//    func getAuthedCarList(userID: String) -> String {
//        return website + "/profile/\(userID)/authed_cars"
//    }
//    
//    func authenticateSportscar() -> String{
//        return website + "/cars/auth"
//    }
//}
//
//
//class SportCarRequester: AccountRequester {
//    
//    static let sharedSCRequester = SportCarRequester()
//    
//    /**
//     根据生产商和汽车的名字检索跑车对象并返回详细信息
//     
//     - parameter manufacturer: 生产商名称
//     - parameter carName:      车型名称
//     - parameter onSuccess:    成功以后调用这个
//     - parameter onError:      失败以后调用这个
//     */
//    func querySportCarWith(manufacturer: String, carName: String, onSuccess: (data: JSON)->(), onError: (code: String?)->()){
//        let urlStr = SportCarURLMaker.sharedMaker.querySportCar()
//        self.manager.request(.GET, urlStr, parameters: ["manufacturer": manufacturer, "car_name": carName]).responseJSON { (response) -> Void in
//            switch response.result {
//            case .Success(let data):
//                let json = JSON(data)
//                if json["success"].boolValue {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        onSuccess(data: json["data"])
//                    })
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        onError(code: json["code"].string)
//                    })
//                }
//                break
//            case .Failure(_):
//                break
//            }
//        }
//    }
//    
//    /**
//     关注某一辆汽车，但是并不认证
//     
//     - parameter signature: 跑车签名
//     - parameter carId:     跑车id
//     - parameter onSuccess: 成功以后调用这个
//     - parameter onError:   失败以后调用这个
//     */
//    func postToFollow(signature:String?, carId: String, onSuccess: (json: JSON?)->(), onError: (code: String?)->()) {
//        let urlStr = SportCarURLMaker.sharedMaker.followSportCar(carId)
//       
//        self.manager.request(.POST, urlStr, parameters: ["signature": signature ?? ""]).responseJSON { (response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "data", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     获取某个用户经过认证的所有跑车的信息
//     
//     - parameter userID:    用户uid
//     - parameter onSuccess: 成功以后调用这个
//     - parameter onError:   失败以后调用这个
//     */
//    func getAuthedCarsList(userID: String, onSuccess: (JSON?)->(), onError: (code: String?)->()) {
//        let urlStr = SportCarURLMaker.sharedMaker.getAuthedCarList(userID)
//        
//        self.manager.request(.GET, urlStr).responseJSON { (let response) -> Void in
//            self.resultValueHandler(response.result, dataFieldName: "cars", onSuccess: onSuccess, onError: onError)
//        }
//    }
//    
//    /**
//     申请认证车辆
//     
//     - parameter carID:        待认证车辆的id
//     - parameter driveLicense: 驾照照片
//     - parameter photo:        人车合照
//     - parameter idCard:       身份证
//     - parameter licenseNum:   车牌照
//     */
//    func authenticateSportscar(carID: String, driveLicense: UIImage, photo: UIImage, idCard: UIImage, licenseNum: String, onSuccess: (JSON?)->(), onProgress: (progress: Float)->(), onError: (code: String?)->()) {
//        let url = SportCarURLMaker.sharedMaker.authenticateSportscar()
//        manager.upload(.POST, url, multipartFormData: { (form) -> Void in
//            form.appendBodyPart(data: carID.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "car_id")
//            form.appendBodyPart(data: UIImagePNGRepresentation(driveLicense)!, name: "drive_license", fileName: "drive_license.png", mimeType: "image/png")
//            form.appendBodyPart(data: UIImagePNGRepresentation(photo)!, name: "photo", fileName: "photo.png", mimeType: "image/png")
//            form.appendBodyPart(data: UIImagePNGRepresentation(idCard)!, name: "id_card", fileName: "id_card", mimeType: "image/png")
//            form.appendBodyPart(data: licenseNum.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "license")
//            }) { (result) -> Void in
//                switch result {
//                case .Success(let upload, _, _):
//                    upload.progress({ (_, totalWritten, total) -> Void in
//                        let progress = Float(totalWritten) / Float(total)
//                        onProgress(progress: progress)
//                    })
//                    upload.responseJSON(completionHandler: { (response) -> Void in
//                        self.resultValueHandler(response.result, dataFieldName: "", onSuccess: onSuccess, onError: onError)
//                    })
//                    break
//                case .Failure(_):
//                    onError(code: "0000")
//                    break
//                }
//        }
//    }
//}
