//
//  Location.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import CoreLocation


class Location {
    var location: CLLocationCoordinate2D
    var description: String
    
    init (location: CLLocationCoordinate2D, description: String) {
        self.location = location
        self.description = description
    }
    
    init (latitude: Double, longitude: Double, description: String) {
        self.location = CLLocationCoordinate2DMake(latitude, longitude)
        self.description = description
    }
}
