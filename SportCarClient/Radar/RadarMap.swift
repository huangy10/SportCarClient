//
//  RadarMap.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox
import SnapKit


protocol RadarMapDelegate: MGLMapViewDelegate {
    func radarDidUpdateAppearance()
}


class RadarMap: MGLMapView {
    var radarDelegate: RadarMapDelegate? {
        didSet {
            delegate = radarDelegate
        }
    }
    // 监控的坐标
    var monitoredPoints: [String: CLLocation] = [:]
    // 被监控的坐标在屏幕上的位置
    var pointsOnScreen: [String: CGPoint] = [:]
    
    var updator: CADisplayLink!
    
    override init(frame: CGRect, styleURL: NSURL?) {
        super.init(frame: frame, styleURL: styleURL)
        
        updator = CADisplayLink(target: self, selector: "updateMonitoredPoints")
        updator.frameInterval = 1
        updator.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updator.paused = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        updator.paused = true
        updator.invalidate()
    }
    
    func startTracking() {
        updator.paused = false
    }
    
    func updateMonitoredPoints() {
        var dirty = false
        for key in monitoredPoints.keys {
            let center = monitoredPoints[key]
            let coordinate = CLLocationCoordinate2D(latitude: center!.coordinate.latitude, longitude: center!.coordinate.longitude)
            let pointOnScreen = self.convertCoordinate(coordinate, toPointToView: self.superview)
            if let original = pointsOnScreen[key] {
                if original.x != pointOnScreen.x || original.y != pointOnScreen.y {
                    dirty = true
                }
            }else{
                dirty = true
            }
            pointsOnScreen[key] = pointOnScreen
        }
        if dirty {
            radarDelegate?.radarDidUpdateAppearance()
        }
    }
    
    func addPoint(key: String, center: CLLocation) {
        monitoredPoints[key] = center
    }
    
    func removePoint(key: String) {
        monitoredPoints.removeValueForKey(key)
    }
}