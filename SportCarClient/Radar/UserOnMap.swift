//
//  UserOnMap.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/24.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox
import Kingfisher

/// 用户显示在地图上的单元
class UserOnMapView: UIButton {
    /// 实际的地理坐标
    var coordinate: CLLocationCoordinate2D?
    /// 对应的用户数据
    var user: User? {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    
    var size: CGSize
    
    var avatar: UIImageView!
    var avatarCar: UIImageView!
    /// 上次更改的数据的时间
    var updatedAt: NSDate
    
    init(size: CGSize) {
        self.size = size
        updatedAt = NSDate()
        super.init(frame: CGRectZero)
        
        createSubviews()
        self.bounds = CGRectMake(0, 0, size.width, size.height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        avatar = UIImageView()
        avatar.layer.cornerRadius = size.width / 2
        avatar.clipsToBounds = true
        self.addSubview(avatar)
        avatar.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        //
        avatarCar = UIImageView()
        avatarCar.layer.cornerRadius = size.width / 2 * 0.385
        avatarCar.clipsToBounds = true
        self.addSubview(avatarCar)
        avatarCar.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.size.equalTo(size.width * 0.385)
        }
    }
    
    func loadDataAndUpdateUI() {
        if user == nil {
            return
        }
        avatar.kf_setImageWithURL(SFURL(user!.avatarUrl!)!)
        if let avatarCarURL = user?.profile?.avatarCarLogo {
            avatarCar.kf_setImageWithURL(SFURL(avatarCarURL)!)
        }
        updatedAt = NSDate()
    }
    
}

