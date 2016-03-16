//
//  UserPin.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class UserAnnotation: BMKPointAnnotation {
    var user: User!
}

class UserAnnotationView: BMKAnnotationView {
    var parent: UIViewController!
    var user: User! {
        didSet {
            if let avatarURL = SFURL(user.avatarUrl!) {
                avatar.kf_setImageWithURL(avatarURL, forState: .Normal)
            }
            if let avatarCarURLStr = user.profile!.avatarCarLogo {
                avatarCar.kf_setImageWithURL(SFURL(avatarCarURLStr)!)
            }
        }
    }
    var avatar: UIButton!
    var avatarCar: UIImageView!
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.bounds = CGRectMake(0, 0, 65, 65)
        avatar = UIButton()
        avatar.layer.cornerRadius = 32.5
        avatar.clipsToBounds = true
        self.addSubview(avatar)
        avatar.addTarget(self, action: "avatarPressed", forControlEvents: .TouchUpInside)
        avatar.frame = CGRectMake(0, 0, 65, 65)
        
        avatarCar = UIImageView()
        avatarCar.layer.cornerRadius = 12.5
        self.addSubview(avatarCar)
        avatarCar.frame = CGRectMake(40, 40, 25, 25)
    }
    
    func avatarPressed() {
        let detail = PersonOtherController(user: user)
        parent.navigationController?.pushViewController(detail, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HostUserOnRadarAnnotationView: BMKAnnotationView {
    var centerIcon: UIImageView!
    var scan: UIImageView!
    
    private var _curAngle: CGFloat = 0
    private var updator: CADisplayLink?
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.bounds = CGRectMake(0, 0, 400, 400)
        self.userInteractionEnabled = false
        
        centerIcon = UIImageView(image: UIImage(named: "location_mark"))
        self.addSubview(centerIcon)
        centerIcon.center = CGPointMake(200, 200)
        centerIcon.bounds = CGRectMake(0, 0, 27.5, 30)
        
        scan = UIImageView(image: UIImage(named: "location_radar_scan"))
        scan.frame = self.bounds
        self.addSubview(scan)
        
        updator = CADisplayLink(target: self, selector: "scanUpdate")
        updator?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updator?.frameInterval = 1
        updator?.paused = true
    }
    
    deinit {
        updator?.invalidate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startScan() {
        updator?.paused = false
    }
    
    func scanUpdate() {
        let trans = CGAffineTransformMakeRotation(_curAngle)
        scan.transform = trans
        _curAngle += 0.03
        self.setNeedsDisplay()
    }
}