//
//  PrivateSettingsCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/6.
//  All cells used in the private settings
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class PrivateChatSettingsHeader: UITableViewHeaderFooterView {
    var titleLbl: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        titleLbl.textColor = UIColor.blackColor()
        self.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(15)
            make.centerY.equalTo(self)
        }
//        let sepLine1 = UIView()
//        sepLine1.backgroundColor = UIColor(white: 0.72, alpha: 1)
//        self.addSubview(sepLine1)
//        sepLine1.snp_makeConstraints { (make) -> Void in
//            make.right.equalTo(self)
//            make.bottom.equalTo(self)
//            make.left.equalTo(self)
//            make.height.equalTo(0.5)
//        }
//        //
//        let sepLine2 = UIView()
//        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
//        self.addSubview(sepLine2)
//        sepLine2.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(self)
//            make.right.equalTo(self)
//            make.top.equalTo(self)
//            make.height.equalTo(0.5)
//        }
    }
}

class PrivateChatSettingsAvatarCell: UITableViewCell {
    static let reuseIdentifier = "private_chat_settings_avatar_cell"
    var avatarImage: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        //
        avatarImage = UIImageView()
        avatarImage.clipsToBounds = true
        avatarImage.layer.cornerRadius = 37
        avatarImage.contentMode = .ScaleAspectFill
        self.contentView.addSubview(avatarImage)
        avatarImage.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.contentView)
            make.size.equalTo(74)
        }
        //
        let icon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        self.contentView.addSubview(icon)
        icon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        
    }
}

class PrivateChatSettingsCommonCell: UITableViewCell {
    static let reuseIdentifier = "private_chat_settings_common_cell"
    
    var staticLbl: UILabel!
    var infoLbl: UILabel!
    var icon: UIImageView!
    var boolSelect: UISwitch!
    var markIcon: UIImageView!
    
    var editable: Bool = true {
        didSet  {
            if editable {
                infoLbl.textColor = UIColor.blackColor()
            }else {
                infoLbl.textColor = UIColor(white: 0.72, alpha: 1)
            }
        }
    }
    
    var useAsMark: Bool = false {
        didSet {
            if useAsMark {
                infoLbl.hidden = true
                icon.hidden = true
                boolSelect.hidden = true
            }else {
                infoLbl.hidden = false
                icon.hidden = false
                boolSelect.hidden = false
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        //
        staticLbl = UILabel()
        staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(staticLbl)
        staticLbl.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
        }
        //
        icon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(icon)
        icon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(staticLbl)
            make.right.equalTo(superview).offset(-15)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        //
        infoLbl = UILabel()
        infoLbl.textColor = UIColor.blackColor()
        infoLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(infoLbl)
        infoLbl.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(staticLbl)
            make.right.equalTo(icon.snp_left).offset(-15)
        }
        //
        boolSelect = UISwitch()
        boolSelect.tintColor = UIColor(white: 0.72, alpha: 1)
        boolSelect.onTintColor = kHighlightedRedTextColor
        boolSelect.backgroundColor = UIColor(white: 0.72, alpha: 1)
        boolSelect.layer.cornerRadius = 15.5
        superview.addSubview(boolSelect)
        boolSelect.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(staticLbl)
            make.size.equalTo(CGSizeMake(51, 31))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
//            make.bottom.equalTo(superview)
            make.top.equalTo(staticLbl.snp_bottom).offset(11)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(0.5)
            make.left.equalTo(superview).offset(15)
        }
        //
        markIcon = UIImageView(image: UIImage(named: "hook"))
        superview.addSubview(markIcon)
        markIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(staticLbl)
            make.size.equalTo(CGSizeMake(17, 12))
        }
        markIcon.hidden = true
    }
}