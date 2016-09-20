//
//  File.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON


class LocationModel: BaseInMemModel {
    var latitude: Double = 0
    var longitude: Double = 0
    var descr: String = ""
    var city: String = ""
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    override func fromJSONString(_ string: String, detailLevel: Int) throws -> LocationModel{
        if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = JSON(data: data)
            // Location does not have a id, so just leave it a positive value
            ssid = 1
            try loadDataFromJSON(json)
            return self
        } else {
            throw SSModelError.invalidJSONString
        }
    }
    
    override func loadDataFromJSON(_ data: JSON) throws -> LocationModel {
        try super.loadDataFromJSON(data)
        latitude = data["lat"].doubleValue
        longitude = data["lon"].doubleValue
        descr = data["description"].stringValue
        city = data["city"].stringValue
        if latitude == 0 && longitude == 0 {
            throw SSModelError.invalidJSON
        }
        return self
    }
    
    override func toJSONObject(_ detailLevel: Int) throws -> JSON {
        return [
            "lat": latitude,
            "lon": longitude,
            "des": descr,
            "city": city
            ] as JSON
    }
}
