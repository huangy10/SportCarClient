//
//  UsrMapLocationMark.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class UserMapLocationManager: UIView {
    var _size: CGSize = CGSize.zero
    
    var centerMark: UIImageView!
    var radarScan: UIImageView!
    var updator: CADisplayLink!
    
    var _curAngle: CGFloat = 0
    
    init(size: CGSize) {
        super.init(frame: CGRect.zero)
        _size = size
        self.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
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
        centerMark.center = CGPoint(x: _size.width / 2, y: _size.height / 2)
        centerMark.bounds = CGRect(x: 0, y: 0, width: 27.5, height: 30)
        //
        radarScan = UIImageView(image: UIImage(named: "location_radar_scan"))
        self.addSubview(radarScan)
        radarScan.frame = CGRect(x: 0, y: 0, width: _size.width, height: _size.width)
        radarScan.transform = CGAffineTransform(rotationAngle: 3.14 / 2)
        //
        updator = CADisplayLink(target: self, selector: #selector(UserMapLocationManager.scanUpdate))
        updator.isPaused = true
        updator.preferredFramesPerSecond = 30
//        updator.frameInterval = 1 // deprecated
        updator.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        updator.isPaused = false
    }
    
    func scanUpdate() {
        let trans = CGAffineTransform(rotationAngle: _curAngle)
        radarScan.transform = trans
        self.setNeedsDisplay()
        _curAngle += 0.03
    }
}
