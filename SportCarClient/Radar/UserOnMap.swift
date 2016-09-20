//
//  UserOnMap.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/24.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

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
    var updatedAt: Date
    
    init(size: CGSize) {
        self.size = size
        updatedAt = Date()
        super.init(frame: CGRect.zero)
        
        createSubviews()
        self.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
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
        avatar.kf_setImageWithURL(user!.avatarURL!)
        if let avatarURL = user?.avatarCarModel?.logoURL {
            avatarCar.kf_setImageWithURL(avatarURL)
        }
        updatedAt = Date()
    }
    
}

