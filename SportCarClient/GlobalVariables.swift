//
//  GlobalVariables.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/7.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import Foundation
import UIKit


// Colors
let kBarBgColor = UIColor(red: 0.09, green: 0.075, blue: 0.075, alpha: 1)
let kHighlightedRedTextColor = UIColor(red: 1, green: 0.267, blue: 0.274, alpha: 1)
let kPlaceholderTextColor = UIColor(white: 0.72, alpha: 1)

// Fonts
let kBarTextFont = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
let kBarTitleFont = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
let kTextInputFont = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)

// Network
let kHostName = "localhost"
let kPortName = "8000"
let kProtocalName = "http"
let mapStyleURL = NSURL(string: "mapbox://styles/woodyhuang1992/ciigr1ml4009q9xkjihwlpgbh")


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
    formatter.dateFormat = "yyyy-MM-dd a HH:mm:ss a"
    return formatter.dateFromString(str!)
}