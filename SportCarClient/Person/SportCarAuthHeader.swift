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
    var authLbl: UILabel!
    var authed: Bool = false {
        didSet {
            if authed {
                authLbl.text = LS("已认证")
            } else {
                authLbl.text = LS("申请认证")
            }
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        authBtn = UIButton()
        let superview = self.contentView
        superview.addSubview(authBtn)

        authBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(titleLbl)
            make.height.equalTo(superview)
            make.width.equalTo(60)
        }
        
        authLbl = authBtn.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightUltraLight, textColor: kHighlightedRedTextColor, textAlignment: .Right, text: LS("申请认证"))
            .layout({ (make) in
                make.edges.equalTo(authBtn)
            })
    }
    
}
