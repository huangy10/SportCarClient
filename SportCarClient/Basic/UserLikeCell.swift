//
//  UserLikeCell.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/22.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class UserLikeCell: DriverMapUserCell {
    override func updateDistanceLbl() {
        if let des = user.recentStatusDes, des != "" {
            distanceLbl.text = des
        } else {
            distanceLbl.text = LS("还没有动态")
        }
    }
}

typealias UserFullInfoCell = UserLikeCell
