//
//  ClubDiscoverListCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ClubDiscoverCell: DriverMapUserCell {
//    var valueLbl: UILabel!
    weak var club: Club!
    
    override func createSubviews() {
        super.createSubviews()
//        valueLbl = UILabel()
//        valueLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)
//        valueLbl.textColor = UIColor(white: 0, alpha: 0.58)
//        self.contentView.addSubview(valueLbl)
//        valueLbl.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(nameLbl.snp_right).offset(5)
//            make.centerY.equalTo(nameLbl)
//        }
    }
    
    override func loadDataAndUpdateUI() {
        avatar.kf.setImage(with: club.logoURL!)
        nameLbl.text = club.name! + "(\(club.memberNum))"
        let valueDes = LS("价值") + "\(club.value/10000)万"
        if let city = club.city {
            distanceLbl.text = city + " " + valueDes
        } else {
            distanceLbl.text = valueDes
        }
    }
}
