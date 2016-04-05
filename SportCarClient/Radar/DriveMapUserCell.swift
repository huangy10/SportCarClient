//
//  DriveMapUserCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation


class DriverMapUserCell: UITableViewCell {
    
    var user: User!
    var userLoc: CLLocation!
    var hostLoc: CLLocation!
    
    var avatar: UIImageView!
    var distanceLbl: UILabel!
    var nameLbl: UILabel!
    var avatarClubLogo: UIButton!
    var avatarClubLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        avatar = UIImageView()
        superview.addSubview(avatar)
        avatar.layer.cornerRadius = 17.5
        avatar.clipsToBounds = true
        avatar.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(25)
            make.size.equalTo(35)
        }
        //
        nameLbl = UILabel()
        nameLbl.textColor = UIColor.blackColor()
        nameLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        superview.addSubview(nameLbl)
        nameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(13)
            make.top.equalTo(avatar)
        }
        //
        avatarClubLogo = UIButton()
        avatarClubLogo.layer.cornerRadius = 10
        avatarClubLogo.clipsToBounds = true
        superview.addSubview(avatarClubLogo)
        avatarClubLogo.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLbl.snp_right).offset(9)
            make.centerY.equalTo(nameLbl)
            make.size.equalTo(20)
        }
        //
        avatarClubLbl = UILabel()
        avatarClubLbl.textColor = UIColor(white: 0.72, alpha: 1)
        avatarClubLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(avatarClubLbl)
        avatarClubLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarClubLogo.snp_right).offset(4)
            make.centerY.equalTo(avatarClubLogo)
        }
        //
        distanceLbl = UILabel()
        distanceLbl.textColor = UIColor(white: 0.72, alpha: 1)
        distanceLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(distanceLbl)
        distanceLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLbl)
            make.top.equalTo(nameLbl.snp_bottom).offset(3)
        }
        //
        let arrow = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrow)
        arrow.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(avatar)
            make.right.equalTo(superview).offset(-25)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
            make.height.equalTo(0.5)
        }
    }
    
    func loadDataAndUpdateUI() {
        avatar.kf_setImageWithURL(user.avatarURL!)
        nameLbl.text = user.nickName
        var distance = hostLoc.distanceFromLocation(userLoc)
        var showKM = false
        if distance > 1000 {
            distance = distance / 1000
            showKM = true
        }
        distanceLbl.text = LS("距离你  ") + "\(Int(distance))" + (showKM ? "km" : "m")
    }
    
}
