//
//  GlobalVariables.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/7.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import SwiftyJSON
// Type define
typealias SSSuccessCallback = (json: JSON?) -> Void
typealias SSFailureCallback = (code: String?) -> Void
typealias SSProgressCallback = (progress: Float) -> Void

// Colors
let kBarBgColor = UIColor(red: 0.09, green: 0.075, blue: 0.075, alpha: 1)
let kHighlightedRedTextColor = UIColor(red: 1, green: 0.267, blue: 0.274, alpha: 1)
let kPlaceholderTextColor = UIColor(white: 0.72, alpha: 1)

// Fonts
let kBarTextFont = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
let kBarTitleFont = UIFont.systemFontOfSize(17, weight: UIFontWeightBlack)
let kTextInputFont = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)

// Network
let kHostName = "localhost"
//let kHostName = "111.206.219.158"
let kPortName = "80"
let kChatPortName = "8888"
let kProtocalName = "http"

//
let kMaxPhotoSelect: Int = 9    // 最大可以选择的照片的数量


//
let kEarchPerimeter: Double = 40075   // 地球周长（KM）

// Macro
func LS(str: String, comment: String="") -> String{
    return NSLocalizedString(str, comment: "")
}

/**
 这个宏在静态文件地址前方加上域名
 
 - parameter urlStr: 返回的完整的路径
 */
func SF(urlStr: String?)->String?{
    if urlStr == nil {
        return nil
    }
    return kProtocalName + "://" + kHostName + ":" + kPortName + urlStr!
}

/**
 这个类似于SF，但是返回的是NSURL对象
 
 - parameter urlString: 没有补全的静态文件路径
 
 - returns: NSURL的下载地址
 */
func SFURL(urlString: String) -> NSURL? {
    let fullURLString = SF(urlString)!
    return NSURL(string: fullURLString)
}


/**
 从字符串形式创建NSDate对象
 
 - parameter str:
 
 - returns:
 */
func DateSTR(str: String?) -> NSDate? {
    if str == nil {
        return nil
    }
    let formatter = NSDateFormatter()
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS Z"
    return formatter.dateFromString(str!)
}

/**
 从NSDate创建字符串
 
 - parameter date: -
 
 - returns: -
 */
func STRDate(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS z"
    formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    return formatter.stringFromDate(date)
}

func dateDisplay(date: NSDate) -> String {
    // 到现在的时间
    let timeDelta = -(date.timeIntervalSinceNow)
    var result: String = ""
    let timeRegion = Region(calType: CalendarType.Gregorian)
    if timeDelta < 300 {
        // 五分钟显示『刚刚』
        result = LS("刚刚")
    }else if timeDelta < 3600{
        // 一小时内显示分钟
        result = "\(Int(timeDelta / 60))" + LS("分钟前")
    }else if timeDelta < 86400 {
        // 一天内显示小时
        result = date.toString(DateFormat.Custom("HH:mm"), inRegion: timeRegion)!
    }else if timeDelta < 172800 {
        result = LS("昨天") + date.toString(DateFormat.Custom("HH:mm"), inRegion: timeRegion)!
    }else {
        result = date.toString(DateFormat.Custom("MM\(LS("月"))dd\(LS("日")) HH:mm"), inRegion: timeRegion)!
    }
    return result
}

func dateDisplayExact(date: NSDate?) -> String? {
    if date == nil {
        return nil
    }
    let timeRegion = Region(calType: CalendarType.Gregorian)
    return date!.toString(DateFormat.Custom("MM\(LS("月"))dd\(LS("日")) HH:mm"), inRegion: timeRegion)!
}

func dateDisplayHHMM(date: NSDate?) -> String! {
    if date == nil {
        return nil
    }
    let timeRegion = Region(calType: CalendarType.Gregorian)
    return date!.toString(DateFormat.Custom("HH:mm"), inRegion: timeRegion)!
}