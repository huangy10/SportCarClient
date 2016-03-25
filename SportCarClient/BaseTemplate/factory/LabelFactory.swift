//
//  LabelFactory.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/24.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


func ss_createLabel(
    font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment,
    text: String? = nil
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.text = text
        return label
}

/**
 Factory function which is able to return a function who will create UILabel with given attributes
 
 - parameter font:          font
 - parameter textColor:     color
 - parameter textAlignment: alignment
 
 - returns: the factory function
 */
func ss_labelFactory(
    font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment
    ) -> ((String)->UILabel) {
        func wrapped(text: String) -> UILabel {
            return ss_createLabel(font, textColor: textColor, textAlignment: textAlignment, text: text)
        }
        return wrapped
}