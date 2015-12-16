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


// Macro
func LS(str: String, comment: String="") -> String{
    return NSLocalizedString(str, comment: "")
}

/**
 这个宏在静态文件地址前方加上域名
 
 - parameter urlStr: 返回的完整的路径
 */
func SF(urlStr: String)->String{
    return kProtocalName + "://" + kHostName + ":" + kPortName + urlStr
}