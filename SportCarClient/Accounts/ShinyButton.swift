//
//  ShinyButton.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class ShinyButton: UIView {
    var timer: Timer?
    var borderWidth = CGFloat(3)   // 边框的宽度
    var brightBorderColor = UIColor(red: 1, green: 0.28, blue: 0.30, alpha: 1)  // 边框部分闪亮的颜色
    var speed = CGFloat(3)       // in Point/100ms
    
    var preScreenShot: UIImage?
    var prePoint = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        let context = UIGraphicsGetCurrentContext()
        if preScreenShot != nil{
            preScreenShot?.draw(in: self.bounds)
            preScreenShot?.draw(in: self.bounds, blendMode: .normal, alpha: 1)
        }
        
        // 计算新的绘图点的坐标
        var curPoint = prePoint
        if curPoint.y == 0 && curPoint.x < width {
            curPoint.x = min(curPoint.x + speed, width)
        }else if curPoint.x == width && curPoint.y < height {
            curPoint.y = min(curPoint.y + speed, height)
        }else if curPoint.y == height && curPoint.x > 0 {
            curPoint.x = max(curPoint.x - speed, 0)
        }else{
            curPoint.y = max(curPoint.y - speed, 0)
        }
        
        context?.saveGState()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: prePoint.x, y: prePoint.y))
        path.addLine(to: CGPoint(x: curPoint.x, y: curPoint.y))
//        CGPathMoveToPoint(path, nil, prePoint.x, prePoint.y)
//        CGPathAddLineToPoint(path, nil, curPoint.x, curPoint.y)
        context?.setStrokeColor(UIColor.green.cgColor)
        context?.setLineWidth(self.borderWidth)
        context?.addPath(path)
        context?.strokePath()
        context?.restoreGState()
        
        preScreenShot = saveCurrentImage()
        
        prePoint = curPoint
    }
    
    func saveCurrentImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, CGFloat(1))
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        // self.drawRect(self.bounds)
        let result =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func updateSelf() {
        // 周期性地更新页面
        self.setNeedsDisplay()
    }
    
    func start() {
        preScreenShot = nil
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ShinyButton.updateSelf), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
}
