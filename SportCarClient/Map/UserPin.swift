//
//  UserPin.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import MapKit

let PinSize: CGFloat = 55

class UserAnnotation: BMKPointAnnotation {
    var user: User!
    var onMap: Bool = true
    
    override init() {
        super.init()
        self.title = " "
    }
}

class UserAnnotationView: BMKAnnotationView {
    weak var parent: UIViewController!
    var user: User! {
        didSet {
            avatar.kf.setImage(with: user.avatarURL!, for: .normal)
            if let avatarCarURL = user.avatarCarModel?.logoURL {
                avatarCar.kf.setImage(with: avatarCarURL)
            }
            if user.identified {
                avatar.layer.borderColor = kHighlightRed.cgColor
                avatar.layer.borderWidth = 2
            } else {
                avatar.layer.borderColor = nil
            }
        }
    }
    var avatar: UIButton!
    var avatarCar: UIImageView!
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.bounds = CGRect(x: 0, y: 0, width: PinSize, height: PinSize)
        avatar = self.addSubview(UIButton.self)
            .config(self, selector: #selector(avatarPressed))
            .setFrame(CGRect(x: 0, y: 0, width: PinSize, height: PinSize))
            .toRound()
        avatarCar = self.addSubview(UIImageView.self)
            .config(nil)
            .setFrame(CGRect(x: PinSize - 25, y: PinSize - 25, width: 25, height: 25))
            .toRound()
        self.addShadow()
    }
    
//    @available(*, deprecated=1)
    func avatarPressed() {
//        let detail = PersonOtherController(user: user)
        parent.navigationController?.pushViewController(user.showDetailController(), animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HostUserOnRadarAnnotationView: BMKAnnotationView {
    var centerIcon: UIImageView!
    var scan: UIImageView!
    
    fileprivate var _curAngle: CGFloat = 0
    fileprivate var updator: CADisplayLink?
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.bounds = CGRect(x: 0, y: 0, width: 400, height: 400)
        self.isUserInteractionEnabled = false
        
        centerIcon = UIImageView(image: UIImage(named: "location_mark"))
        self.addSubview(centerIcon)
        centerIcon.center = CGPoint(x: 200, y: 200)
        centerIcon.bounds = CGRect(x: 0, y: 0, width: 27.5, height: 30)
        
        scan = UIImageView(image: UIImage(named: "location_radar_scan"))
        scan.frame = self.bounds
        self.addSubview(scan)
        
        updator = CADisplayLink(target: self, selector: #selector(HostUserOnRadarAnnotationView.scanUpdate))
        updator?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
//        updator?.frameInterval = 1
        updator?.preferredFramesPerSecond = 30
        updator?.isPaused = true
        
        self.isUserInteractionEnabled = false
    }
    
    deinit {
        updator?.invalidate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startScan() {
        updator?.isPaused = false
    }
    
    func scanUpdate() {
        let trans = CGAffineTransform(rotationAngle: _curAngle)
        scan.transform = trans
        _curAngle += 0.03
        self.setNeedsDisplay()
    }
}
//
