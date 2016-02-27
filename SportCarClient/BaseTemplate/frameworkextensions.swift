//
//  frameworkextensions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import UIKit


extension String {
    func insert(string: String, atIndex ind: Int) -> String {
        return String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters
            .count - ind))
    }
}


extension NSDate {
    func stringDisplay() -> String? {
        return dateDisplayExact(self)
    }
    
    func isSameDayWith(date: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let comps1 = calendar.components([NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Day], fromDate:self)
        let comps2 = calendar.components([NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Day], fromDate:date)
        
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
}

func CGPointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(dx * dx + dy * dy)
}