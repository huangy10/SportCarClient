//
//  PersonOtherHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class PersonHeaderOther: PersonHeaderMine {
    var followBtn: UIButton!
    var followBtnTmpImage: UIImageView!
    var chatBtn: UIButton!
    var locBtn: UIButton!
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self
        //
        followBtn = UIButton()
        followBtn.setImage(UIImage(named: "person_add_follow"), for: .normal)
        superview.addSubview(followBtn)
        followBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(avatarBtn.snp.centerX).offset(3.5)
            make.top.equalTo(avatarBtn.snp.bottom).offset(24)
            make.size.equalTo(CGSize(width: 130, height: 45))
        }
        followBtnTmpImage = UIImageView()
        followBtnTmpImage.backgroundColor = UIColor.white
        followBtn.addSubview(followBtnTmpImage)
        followBtnTmpImage.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(followBtn)
        }
        followBtnTmpImage.isHidden = true
        //
        chatBtn = UIButton()
        chatBtn.setImage(UIImage(named: "person_send_message"), for: .normal)
        superview.addSubview(chatBtn)
        chatBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(followBtn)
            make.left.equalTo(followBtn.snp.right).offset(15)
            make.size.equalTo(45)
        }
        //
        locBtn = UIButton()
        locBtn.setImage(UIImage(named: "person_guide_to"), for: .normal)
        superview.addSubview(locBtn)
        locBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(followBtn)
            make.left.equalTo(chatBtn.snp.right).offset(15)
            make.size.equalTo(45)
        }
        // 这里需要重新设置下面是三组数字的布局
        fansNumLbl.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(followBtn.snp.bottom).offset(21)
            make.centerX.equalTo(avatarBtn)
        }
        // 更改maskView的高度
        backMask.centerHegiht = 225
        avatarBtn.snp.updateConstraints { (make) -> Void in
            make.bottom.equalTo(self).offset(-156)
        }
        //=
    }
    
    override func loadDataAndUpdateUI() {
        super.loadDataAndUpdateUI()
        if user.followed {
            followBtnTmpImage.image = UIImage(named: "person_followed")
            followBtn.setImage(UIImage(named: "person_followed"), for: .normal)
        }else{
            followBtnTmpImage.image = UIImage(named: "person_add_follow")
            followBtn.setImage(UIImage(named: "person_add_follow"), for: .normal)
        }
    }
}
