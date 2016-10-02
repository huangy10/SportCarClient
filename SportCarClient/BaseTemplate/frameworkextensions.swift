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
    func insert(_ string: String, atIndex ind: Int) -> String {
        return String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters
            .count - ind))
    }
    
    func sizeWithFont(_ font: UIFont, boundingSize: CGSize) -> CGSize {
        return self.boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
    }
}


extension Date {
    func stringDisplay() -> String? {
        return dateDisplayExact(self)
    }
    
    func isSameDayWith(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let comps1 = (calendar as NSCalendar).components([NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.day], from:self)
        let comps2 = (calendar as NSCalendar).components([NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.day], from:date)
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
}

func CGPointDistance(_ p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(dx * dx + dy * dy)
}

extension Timer {
    /**
     Creates and schedules a one-time `NSTimer` instance.
     
     - Parameters:
     - delay: The delay before execution.
     - handler: A closure to execute after `delay`.
     
     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(delay: TimeInterval, handler: @escaping (CFRunLoopTimer?) -> Void) -> Timer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
    
    /**
     Creates and schedules a repeating `NSTimer` instance.
     
     - Parameters:
     - repeatInterval: The interval (in seconds) between each execution of
     `handler`. Note that individual calls may be delayed; subsequent calls
     to `handler` will be based on the time the timer was created.
     - handler: A closure to execute at each `repeatInterval`.
     
     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(repeatInterval interval: TimeInterval, handler: @escaping (CFRunLoopTimer?) -> Void) -> Timer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer!
    }
    
}


