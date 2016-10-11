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
    
    override func createSubviews() {
        super.createSubviews()
        //
        configureFollowBtn()
    }
    
    func configureFollowBtn() {
        followBtn = addSubview(UIButton.self)
            .layout({ (make) in
                make.centerY.equalTo(fansNumLbl.snp.bottom)
                make.right.equalTo(self).offset(-15)
                make.width.equalTo(78)
                make.height.equalTo(25)
            })
        followBtn.layer.cornerRadius = 2
        followBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        set(followed: false)
    }
    
    func set(followed isFollowed: Bool) {
        if isFollowed {
            followBtn.layer.borderColor = UIColor.clear.cgColor
            followBtn.backgroundColor = UIColor(white: 0.96, alpha: 1)
            followBtn.setTitle(LS("已关注"), for: .normal)
            followBtn.setTitleColor(kTextGray38, for: .normal)
        } else {
            followBtn.layer.borderColor = kHighlightRed.cgColor
            followBtn.backgroundColor = UIColor.clear
            followBtn.layer.borderWidth = 1
            followBtn.setTitle(LS("+ 关注"), for: .normal)
            followBtn.setTitleColor(kHighlightRed, for: .normal)
        }
    }
    
    override func layoutBottomLbls() {
        fansNumLbl.snp.makeConstraints { (make) in
            make.top.equalTo(avatarBtn.snp.bottom).offset(23)
            make.left.equalTo(nameLbl)
        }
        statusNumLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(fansNumLbl).offset(-80)
            make.centerY.equalTo(fansNumLbl)
        }
        followNumLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(fansNumLbl).offset(80)
            make.centerY.equalTo(fansNumLbl)
        }
    }
    
    override func setAppearance(ofBottomLbls label: UILabel) {
        super.setAppearance(ofBottomLbls: label)
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
    }
    
    override func loadDataAndUpdateUI() {
        super.loadDataAndUpdateUI()
        set(followed: user.followed)
    }
}
