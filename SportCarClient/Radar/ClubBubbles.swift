//
//  ClubBubbles.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol ClubBubbleViewDelegate: class {
    
    func clubBubbleDidClickOn(_ club: Club)
    
}


class ClubBubbleView: UIView {
    
    weak var delegate: ClubBubbleViewDelegate?
    var bubbles: [ClubBubbleCell] = []
    var clubs: [Club] = []
    var updator: CADisplayLink?
    weak var aaa: UIViewController?
    
    func reloadBubble() {
        updator?.invalidate()
        for bubble in bubbles {
            bubble.removeFromSuperview()
        }
        bubbles.removeAll()
    
        for club in clubs {
            let bubble = ClubBubbleCell()
            bubble.addTarget(self, action: #selector(ClubBubbleView.bubblePressed(_:)), for: .touchUpInside)
            bubble.borderLimit = self.bounds
            bubble.club = club
            bubbles.append(bubble)
            self.addSubview(bubble)
            
            let displayCenter = CGPoint(x: bounds.midX, y: bounds.midY)
            let initAngle = CGFloat(arc4random_uniform(360)) / 360 * 3.141592 * 2
            bubble.center = CGPoint(x: displayCenter.x + 500 * cos(initAngle), y: displayCenter.y + 500 * sin(initAngle))
            bubble.speed = CGPoint(x: -cos(initAngle) * 3, y: -sin(initAngle) * 3)
            
            self.bubbles.append(bubble)
        }
    }
    
    func startUpdate() {
        updator?.invalidate()
        updator = CADisplayLink(target: self, selector: #selector(ClubBubbleView.update))
        updator?.frameInterval = 0
        updator?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func endUpdate() {
        updator?.isPaused = true
        updator?.invalidate()
        updator = nil
    }
    
    func update() {
        for x in bubbles {
            x.update()
            for y in bubbles {
                if x == y {
                    continue
                }
                if CGPointDistance(x.center, p2: y.center) < (x.radius + y.radius) {
                    ClubBubbleCell.collide(x, b2: y)
                    break
                }
            }
        }
    }
    
    func bubblePressed(_ sender: ClubBubbleCell) {
        delegate?.clubBubbleDidClickOn(sender.club!)
    }
}


class ClubBubbleCell: UIButton {
    
    var club: Club? {
        didSet {
            if club != nil {
                let logoURL = club!.logoURL!
                self.kf_setImageWithURL(logoURL, forState: UIControlState())
                switch club!.memberNum {
                case 0..<30:
                    radius = 30
                case 30..<50:
                    radius = 40
                case 50..<80:
                    radius = 47.5
                default:
                    radius = 50
                }
                self.backgroundColor = UIColor(white: 0.72, alpha: 1)
            }
        }
    }
    
    var radius: CGFloat = 10 {
        didSet {
            self.bounds = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
        }
    }
    var borderCheckEnabled: Bool = false
    var mass: CGFloat {
        return radius * radius
    }
    // speed of the bubble
    var speed: CGPoint = CGPoint(x: 0, y: 0)
    var slowDownRate: CGFloat = 0.995
    var borderLimit: CGRect = CGRect.zero
    
    func update() {
        if borderCheckEnabled {
            slowDown()
        }
        borderCheck()
        gravity()
        var newCenter = center
        newCenter.x += speed.x
        newCenter.y += speed.y
        center = newCenter
    }
    
    fileprivate func slowDown() {
        speed.x *= slowDownRate
        speed.y *= slowDownRate
    }
    
    fileprivate func borderCheck() {
        if !borderCheckEnabled {
            if borderLimit.contains(bounds) {
                borderCheckEnabled = true
            } else {
                return
            }
        }
        let x = center.x
        let y = center.y
        if x + radius > bounds.origin.x + borderLimit.width {
            speed.x = -abs(speed.x)
        }

        if x - radius < bounds.origin.x {
            speed.x = abs(speed.x)
        }

        if y + radius > bounds.origin.y + borderLimit.height {
            speed.y = -abs(speed.y)
        }

        if y - radius < bounds.origin.y {
            speed.y = abs(speed.y)
        }
    }
    
    fileprivate func gravity() {
        let centerX = borderLimit.origin.x + borderLimit.width / 2
        let centerY = borderLimit.origin.y + borderLimit.height / 2
        //
        let x = (centerX - center.x) / 100 * abs(speed.x) * 0.5
        let y = (centerY - center.y) / 100 * abs(speed.x) * 0.5
        center = CGPoint(x: center.x + x, y: center.y + y)
    }
    
    // collison between bubbles
    class func collide(_ b1: ClubBubbleCell, b2: ClubBubbleCell) {
        let dist1 = CGPointDistance(b1.center, p2: b2.center)
        let dist2 = CGPointDistance(CGPoint(x: b1.center.x + b1.speed.x, y: b1.center.y + b1.speed.y), p2: CGPoint(x: b2.center.x + b2.speed.x, y: b2.center.y + b2.speed.y))
        if dist1 <= dist2 {
            // if the two bubble are leaving, do not exchange their speed vector
            return
        }
        let tmp = b1.speed
        b1.speed = b2.speed
        b2.speed = tmp
        
        b1.speed.x *= 0.999
        b1.speed.y *= 0.999
        b2.speed.x *= 0.999
        b2.speed.y *= 0.999
    }
}
