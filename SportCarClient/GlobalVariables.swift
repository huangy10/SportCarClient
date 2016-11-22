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
typealias SSSuccessCallback = (_ json: JSON?) -> Void
typealias SSFailureCallback = (_ code: String?) -> Void
typealias SSProgressCallback = (_ progress: Float) -> Void

// Colors
let kBarBgColor = UIColor(red: 0.09, green: 0.075, blue: 0.075, alpha: 1)
let kHighlightedRedTextColor = UIColor(red: 1, green: 0.267, blue: 0.274, alpha: 1)
let kPlaceholderTextColor = kTextGray28
let kTextGray87 = UIColor(white: 0, alpha: 0.87)
let kTextGray54 = UIColor(white: 0, alpha: 0.54)
let kTextGray38 = UIColor(white: 0, alpha: 0.38)
let kTextGray28 = UIColor(white: 0.72, alpha: 1)
let kSepLineLightGray = UIColor(white: 0.94, alpha: 1)
let kGeneralTableViewBGColor = UIColor(white: 0.96, alpha: 1)
let kNotificationHintColor = UIColor(white: 0.42, alpha: 1)
let kHighlightRed = UIColor.RGB(255, 21, 21)

// Fonts
let kBarTextFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
let kBarTitleFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
let kTextInputFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)

// Network
//let kHostName = "166.111.17.98"
let kHostName = "paochefan.com"
let kPortName = "80"
let kChatPortName = "8888"
let kProtocalName = "http"
// 在跑车雷达中，当前显示用户最长维持的时间，即如果在这个时间内（秒）没有获取新的数据，则下次打开发现页面是，会清空原来的结果
let kMaxRadarKeptTime: TimeInterval =  600
//
let kMaxPhotoSelect: Int = 9    // 最大可以选择的照片的数量
let kLoadingAppearDelay: Int64 = 300

// video html template

let VIDEO_HTML_TEMPLATE: String = "<body style=\"margin:0;\"><iframe style=\"width:\(UIScreen.main.bounds.width)px; height:\(UIScreen.main.bounds.width / 375 * 220)px; border:0px; margin:0; padding: 0;\" src='%@' frameborder=0 'allowfullscreen'></iframe></body>"

// Macro
func LS(_ str: String, comment: String="") -> String{
    return NSLocalizedString(str, comment: "")
}

/**
 这个宏在静态文件地址前方加上域ORada
 
 - parameter urlStr: 返回的完整的路径
 */ 
func SF(_ urlStr: String?)->String?{
    guard let url = urlStr else {
        return nil
    }
    if url.hasPrefix("http") {
        // support external link
        return url
    }
    return kProtocalName + "://" + kHostName + ":" + kPortName + url
}

/**
 这个类似于SF，但是返回的是NSURL对象
 
 - parameter urlString: 没有补全的静态文件路径
 
 - returns: NSURL的下载地址
 */
func SFURL(_ urlString: String) -> URL? {
    let fullURLString = SF(urlString)!
    return URL(string: fullURLString)
}


/**
 从字符串形式创建NSDate对象
 
 - parameter str:
 
 - returns:
 */
func DateSTR(_ str: String?) -> Date? {
    if str == nil {
        return nil
    }
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS Z"
    return formatter.date(from: str!)
}

/**
 从NSDate创建字符串
 
 - parameter date: -
 
 - returns: -
 */
func STRDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS z"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: date)
}

func dateDisplay(_ date: Date) -> String {
    // 到现在的时间
    let timeDelta = -(date.timeIntervalSinceNow)
    var result: String = ""
//    let timeRegion = Region(components: CalendarName.gregorian)
    let timeRegion = Region(tz: TimeZoneName.current, cal: CalendarName.gregorian, loc: LocaleName.chineseChina)
    
    if timeDelta < 300 {
        // 五分钟显示『刚刚』
        result = LS("刚刚")
    }else if timeDelta < 3600{
        // 一小时内显示分钟
        result = "\(Int(timeDelta / 60))" + LS("分钟前")
    }else if timeDelta < 86400 {
        // 一天内显示小时
        result = date.string(format: .custom("HH:mm"), in: timeRegion)
    }else if timeDelta < 172800 {
        result = LS("昨天") + date.string(format: .custom("HH:mm"), in: timeRegion)
    }else {
        result = date.string(format: .custom("MM\(LS("月"))dd\(LS("日")) HH:mm"), in: timeRegion)
    }
    return result
}

func dateDisplayExact(_ date: Date?) -> String? {
    if date == nil {
        return nil
    }
//    let timeRegion = Region(components: CalendarName.gregorian)
    let timeRegion = Region(tz: TimeZoneName.current, cal: CalendarName.gregorian, loc: LocaleName.chineseChina)
    return date!.string(format: .custom("MM\(LS("月"))dd\(LS("日")) HH:mm"), in: timeRegion)
}

func dateDisplayHHMM(_ date: Date?) -> String! {
    if date == nil {
        return nil
    }
//    let timeRegion = Region(components: CalendarName.gregorian)
    let timeRegion = Region(tz: TimeZoneName.current, cal: CalendarName.gregorian, loc: LocaleName.chineseChina)
    return date!.string(format: .custom("HH:mm"), in: timeRegion)
}
