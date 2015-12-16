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


class SportCarURLMaker: AccountURLMaker {
    static let sharedMaker = SportCarURLMaker(user: nil)
    
    func querySportCar()->String{
        return website + "/cars/querybyname"
    }
    
    func followSportCar(carID: String) -> String {
        return website + "/cars/\(carID)/follow"
    }
}


class SportCarRequester: AccountRequester {
    
    static let sharedSCRequester = SportCarRequester()

    func querySportCarWith(manufacturer: String, carName: String, onSuccess: (data: JSON)->(), onError: (code: String?)->()){
        let urlStr = SportCarURLMaker.sharedMaker.querySportCar()
        self.manager.request(.GET, urlStr, parameters: ["manufacturer": manufacturer, "car_name": carName]).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                if json["success"].boolValue {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        onSuccess(data: json["data"])
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        onError(code: json["code"].string)
                    })
                }
                break
            case .Failure(let error):
                print("\(error)")
                break
            }
        }
    }
    
    func postToFollow(signature:String?, carId: String, onSuccess: ()->(), onError: (code: String?)->()) {
        let urlStr = SportCarURLMaker.sharedMaker.followSportCar(carId)
       
        self.manager.request(.POST, urlStr, parameters: ["signature": signature ?? ""]).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(let data):
                let json = JSON(data)
                if json["success"].boolValue {
                    dispatch_async(dispatch_get_main_queue(), onSuccess)
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        onError(code: json["code"].string)
                    })
                }
                break
            case .Failure(let error):
                print("\(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    onError(code: "0000")
                })
                break
            }
        }
    }
}