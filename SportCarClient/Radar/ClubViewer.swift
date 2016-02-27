//
//  ClubViewer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

func clubBubbleCollide(b1: ClubBubble, b2: ClubBubble) {
    
    let dist1 = CGPointDistance(b1.center, p2: b2.center)
    let dist2 = CGPointDistance(CGPointMake(b1.center.x + b1.speedX, b1.center.y + b1.speedY), p2: CGPointMake(b2.center.x + b2.speedX, b2.center.y + b2.speedY))
    
    if dist1 <= dist2 {
        return
    }
    
    let tmpx = b1.speedX
    let tmpy = b1.speedY
    
    b1.speedX = b2.speedX
    b1.speedY = b2.speedY
    
    b2.speedX = tmpx
    b2.speedY = tmpy
    
    b1.stable = true
    b2.stable = true
}


class ClubBubble: UIButton {
    
    var mass: Double = 100 {
        didSet {
            radius = CGFloat(sqrt(mass)) / 2
            self.bounds = CGRectMake(0, 0, radius * 2, radius * 2)
            self.layer.cornerRadius = radius
        }
    }
    
    var radius: CGFloat = 10
    
    var stable: Bool = false
    
    var speedX: CGFloat = 1
    var speedY: CGFloat = 1
    
    var x: CGFloat {
        get {
            return center.x
        }
        set {
            center = CGPointMake(newValue, center.y)
        }
    }
    
    var y: CGFloat {
        get {
            return center.y
        }
        set {
            center = CGPointMake(center.x, newValue)
        }
    }
    
    func update() {
        let newCenter = CGPointMake(x + speedX, y + speedY)
        self.center = newCenter
    }
    
    func detectBorder(bounds: CGRect) {

        if x + radius > bounds.origin.x + bounds.width {
            speedX = -abs(speedX)
        }
        
        if x - radius < bounds.origin.x {
            speedX = abs(speedX)
        }
        
        if y + radius > bounds.origin.y + bounds.height {
            speedY = -abs(speedY)
        }
        
        if y - radius < bounds.origin.y {
            speedY = abs(speedY)
        }
    }
    
    func slowDown() {
        speedY *= 0.99
        speedX *= 0.99
    }
    
    func gravity(bound: CGRect) {
        let centerX = bounds.origin.x + bound.width / 2
        let centerY = bounds.origin.y + bound.height / 2
        //
        x += (centerX - x) / 100 * abs(speedX) * 0.5
        y += (centerY - y) / 100 * abs(speedY) * 0.5
    }
}


class ClubsController: UIViewController {
    
    var bubbles: [ClubBubble] = []
    
    var constraintBound: CGRect = CGRectMake(0, 100, UIScreen.mainScreen().bounds.width, 180)
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.blackColor()
        self.view.clipsToBounds = true
        testInit()
        
        let updater = CADisplayLink(target: self, selector: "update")
        updater.frameInterval = 0
        updater.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func testInit() {
        
        let displayCenter = CGPointMake(CGRectGetMidX(constraintBound), CGRectGetMidY(constraintBound))
        
        for _ in 0..<12 {
            let bubble = ClubBubble()
            bubble.backgroundColor = UIColor.redColor()
            let mass = Double(random() % 4000) + 1000
            bubble.mass = mass
            bubble.stable = false
            let initAngle = CGFloat(drand48() * M_PI * 2)
            bubble.center = CGPointMake(displayCenter.x + 500 * cos(initAngle), displayCenter.y + 500 * sin(initAngle))
            bubble.speedX = -cos(initAngle) * 3
            bubble.speedY = -sin(initAngle) * 3
            self.view.addSubview(bubble)
            self.bubbles.append(bubble)
        }
    }
    
    func update() {
        for x in bubbles {
            x.update()
            if !x.stable {
                if CGRectContainsRect(constraintBound, x.frame){
                    x.stable = true
                }
            }else {
                x.detectBorder(constraintBound)
                if CGRectContainsRect(constraintBound, x.frame){
                    x.slowDown()
                    x.gravity(constraintBound)
                }
            }
            for y in bubbles {
                if x == y {
                    continue
                }
                // 判断两个bubble是否靠的足够近
                if CGPointDistance(x.center, p2: y.center) < (x.radius + y.radius) {
//                    print(x.center, y.center)
//                    print(CGPointDistance(x.center, p2: y.center))
                    clubBubbleCollide(x, b2: y)
                    break
                }
            }
        }
    }
    
}
