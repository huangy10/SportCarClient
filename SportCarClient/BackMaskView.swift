//
//  BackMaskView.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class BackMaskView: UIView {
    var ratio: CGFloat = 0.1
    var centerHegiht : CGFloat = 100
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        let width = self.frame.width
        let height = self.frame.height
        ctx?.saveGState()
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.move(to: CGPoint(x: 0, y: height))
        ctx?.addLine(to: CGPoint(x: width, y: height))
        let rightHeight = centerHegiht + width * ratio / 2
        let leftHeight = centerHegiht - width * ratio / 2
        ctx?.addLine(to: CGPoint(x: width, y: height - rightHeight))
        ctx?.addLine(to: CGPoint(x: 0, y: height - leftHeight))
        ctx?.closePath()
        ctx?.fillPath()
        ctx?.restoreGState()
    }
}
