//
//  NotificationCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class NotificationBaseCell: UITableViewCell {
    class func reuseIdentifier() -> String{
        return "notification_base_cell"
    }
    
    var avatarBtn: UIButton!
    var nickNameLbl: UILabel!
    var informLbL: UILabel!
    var dateLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        avatarBtn = UIButton()
        avatarBtn.layer.cornerRadius = 45
        superview.addSubview(avatarBtn)
        avatarBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(45)
        }
        //
        nickNameLbl = UILabel()
        nickNameLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        nickNameLbl.textColor = UIColor.blackColor()
        superview.addSubview(nickNameLbl)
        nickNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp_right).offset(15)
            make.bottom.equalTo(avatarBtn.snp_centerY)
        }
        //
        informLbL = UILabel()
        informLbL.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        informLbL.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(informLbL)
        informLbL.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl.snp_right).offset(10)
            make.bottom.equalTo(nickNameLbl)
        }
        //
        dateLbl = UILabel()
        dateLbl.font = UIFont.systemFontOfSize(10, weight: UIFontWeightUltraLight)
        dateLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(dateLbl)
        dateLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl)
            make.top.equalTo(nickNameLbl.snp_bottom).offset(5)
        }
    }
}


class NotificationCellWithCoverThumbnail: NotificationBaseCell {
    
    override class func reuseIdentifier() -> String {
        return "notification_cell_with_cover_thumbnail"
    }
    
    var cover: UIButton!
    var messageBodyLbl: UILabel!
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        
        messageBodyLbl = UILabel()
        messageBodyLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        messageBodyLbl.textColor = UIColor(white: 0.47, alpha: 1)
        superview.addSubview(messageBodyLbl)
        messageBodyLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(avatarBtn)
            make.height.equalTo(avatarBtn)
            make.width.equalTo(messageBodyLbl.snp_height)
        }
    }
}


class NotificationCellAboutActivity: NotificationBaseCell{
    
    override class func reuseIdentifier() -> String {
        return "notification_cell_about_activity"
    }
    
    var name2LbL: UILabel!
    var inform2Lbl: UILabel!
    
    var agreenBtn: UIButton!
    var onAgreeBtnPressed: ((sender: NotificationCellAboutActivity)->())?
    var denyBtn: UIButton!
    var onDenyBtnPressed: ((sender: NotificationCellAboutActivity)->())?
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        //
        name2LbL = UILabel()
        name2LbL.textColor = UIColor.blackColor()
        name2LbL.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        superview.addSubview(name2LbL)
        name2LbL.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(informLbL.snp_right).offset(10)
            make.bottom.equalTo(nickNameLbl) 
        }
        //
        inform2Lbl = UILabel()
        inform2Lbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        inform2Lbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(inform2Lbl)
        inform2Lbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(name2LbL.snp_right).offset(10)
            make.bottom.equalTo(name2LbL)
        }
        //
        agreenBtn = UIButton()
        agreenBtn.setTitle(LS("同意"), forState: .Normal)
        agreenBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        agreenBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(agreenBtn)
        agreenBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview.snp_right).offset(45)
            make.top.equalTo(dateLbl.snp_bottom).offset(13)
            make.size.equalTo(CGSizeMake(44, 20))
        }
        agreenBtn.addTarget(self, action: "agreeBtnPressed", forControlEvents: .TouchUpInside)
        //
        denyBtn = UIButton()
        denyBtn.setTitle(LS("谢绝"), forState: .Normal)
        denyBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        denyBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(denyBtn)
        denyBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(agreenBtn.snp_center).offset(-50)
            make.centerY.equalTo(agreenBtn)
            make.size.equalTo(agreenBtn)
        }
        denyBtn.addTarget(self, action: "denyBtnPressed", forControlEvents: .TouchUpInside)
    }
    
    
    func agreeBtnPresssed() {
        if onAgreeBtnPressed == nil {
            assertionFailure()
        }
        onAgreeBtnPressed!(sender: self)
    }
    
    func denyBtnPressed() {
        if onDenyBtnPressed == nil {
            assertionFailure()
        }
        onDenyBtnPressed!(sender: self)
    }
}
