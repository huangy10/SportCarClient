//
//  SportCarAuthHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class SportCarAuthHeader: SSCommonHeader {
    
    override class var reuseIdentifier: String {
        return "sport_car_auth_header"
    }
    
    var authBtn: UIButton!
    var authed: Bool = false {
        didSet {
            if authed {
                authBtn.setTitle(LS("已认证"), forState: .Normal)
            } else {
                authBtn.setTitle(LS("申请认证"), forState: .Normal)
            }
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        authBtn = UIButton()
        let superview = self.contentView
        superview.addSubview(authBtn)
        authBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        authBtn.setTitle(LS("申请认证"), forState: .Normal)
        authBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        authBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(titleLbl)
            make.height.equalTo(superview)
            make.width.equalTo(60)
        }
    }
    
}
