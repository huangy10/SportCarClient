//
//  PersonOtherHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Mapbox
import Kingfisher


class PersonHeaderOther: PersonHeaderMine {
    var followBtn: UIButton!
    var chatBtn: UIButton!
    var locBtn: UIButton!
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self
        //
        followBtn = UIButton()
        followBtn.setImage(UIImage(named: "person_add_follow"), forState: .Normal)
        superview.addSubview(followBtn)
        followBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(avatarBtn.snp_centerX).offset(3.5)
            make.top.equalTo(avatarBtn.snp_bottom).offset(24)
            make.size.equalTo(CGSizeMake(130, 45))
        }
        //
        chatBtn = UIButton()
        chatBtn.setImage(UIImage(named: "person_send_message"), forState: .Normal)
        superview.addSubview(chatBtn)
        chatBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(followBtn)
            make.left.equalTo(followBtn.snp_right).offset(15)
            make.size.equalTo(45)
        }
        //
        locBtn = UIButton()
        locBtn.setImage(UIImage(named: "person_guide_to"), forState: .Normal)
        superview.addSubview(locBtn)
        locBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(followBtn)
            make.left.equalTo(chatBtn.snp_right).offset(15)
            make.size.equalTo(45)
        }
        // 这里需要重新设置下面是三组数字的布局
        fansNumLbl.snp_remakeConstraints { (make) -> Void in
            make.top.equalTo(followBtn.snp_bottom).offset(21)
            make.centerX.equalTo(avatarBtn)
        }
        // 更改maskView的高度
        backMask.centerHegiht = 225
        avatarBtn.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(self).offset(-156)
        }
    }
}
