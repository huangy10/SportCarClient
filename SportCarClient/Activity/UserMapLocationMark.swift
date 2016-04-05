//
//  UsrMapLocationMark.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class UserMapLocationManager: UIView {
    var _size: CGSize = CGSizeZero
    
    var centerMark: UIImageView!
    var radarScan: UIImageView!
    var updator: CADisplayLink!
    
    var _curAngle: CGFloat = 0
    
    init(size: CGSize) {
        super.init(frame: CGRectZero)
        _size = size
        self.bounds = CGRectMake(0, 0, size.width, size.height)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        updator.invalidate()
    }
    
    func createSubviews() {
        centerMark = UIImageView(image: UIImage(named: "location_mark"))
        self.addSubview(centerMark)
        centerMark.center = CGPointMake(_size.width / 2, _size.height / 2)
        centerMark.bounds = CGRectMake(0, 0, 27.5, 30)
        //
        radarScan = UIImageView(image: UIImage(named: "location_radar_scan"))
        self.addSubview(radarScan)
        radarScan.frame = CGRectMake(0, 0, _size.width, _size.width)
        radarScan.transform = CGAffineTransformMakeRotation(3.14 / 2)
        //
        updator = CADisplayLink(target: self, selector: #selector(UserMapLocationManager.scanUpdate))
        updator.paused = true
        updator.frameInterval = 1
        updator.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updator.paused = false
    }
    
    func scanUpdate() {
        let trans = CGAffineTransformMakeRotation(_curAngle)
        radarScan.transform = trans
        self.setNeedsDisplay()
        _curAngle += 0.03
    }
}
