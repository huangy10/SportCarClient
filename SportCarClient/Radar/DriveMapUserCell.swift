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
    var avatarClubIcon: UIImageView!
    
    var avatarCarLogoIcon: UIImageView!
    var avatarCarNameLbl: UILabel!
    var genderIcon: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
//        let superview = self.contentView
//        superview.backgroundColor = UIColor.white
//        //
//        avatar = UIImageView()
//        superview.addSubview(avatar)
//        avatar.layer.cornerRadius = 17.5
//        avatar.clipsToBounds = true
//        avatar.snp.makeConstraints { (make) -> Void in
//            make.centerY.equalTo(superview)
//            make.left.equalTo(25)
//            make.size.equalTo(35)
//        }
//        //
//        nameLbl = UILabel()
//        nameLbl.textColor = UIColor.black
//        nameLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
//        superview.addSubview(nameLbl)
//        nameLbl.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(avatar.snp.right).offset(13)
//            make.top.equalTo(avatar)
//        }
//        //
//        avatarClubLogo = UIButton()
//        avatarClubLogo.layer.cornerRadius = 10
//        avatarClubLogo.clipsToBounds = true
//        superview.addSubview(avatarClubLogo)
//        avatarClubLogo.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(nameLbl.snp.right).offset(9)
//            make.centerY.equalTo(nameLbl)
//            make.size.equalTo(20)
//        }
//        //
//        distanceLbl = UILabel()
//        distanceLbl.textColor = UIColor(white: 0, alpha: 0.58)
//        distanceLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
//        superview.addSubview(distanceLbl)
//        distanceLbl.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(nameLbl)
//            make.top.equalTo(nameLbl.snp.bottom).offset(3)
//        }
//        //
//        let arrow = UIImageView(image: UIImage(named: "account_btn_next_icon"))
//        superview.addSubview(arrow)
//        arrow.snp.makeConstraints { (make) -> Void in
//            make.centerY.equalTo(avatar)
//            make.right.equalTo(superview).offset(-25)
//            make.size.equalTo(CGSize(width: 9, height: 15))
//        }
//        //
//        let sepLine = UIView()
//        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
//        superview.addSubview(sepLine)
//        sepLine.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.bottom.equalTo(superview)
//            make.height.equalTo(0.5)
//        }
//        
        configureAvatar()
        configureNameLbl()
        configureAvatarClub()
        configureGenderIcon()
        configureDistanceLbl()
        configureAvatarCar()
        configureOtherStaticMarker()
    }
    
    func configureAvatar() {
       avatar = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.centerY.equalToSuperview()
                mk.left.equalTo(25)
                mk.size.equalTo(35)
            })
        avatar.layer.cornerRadius = 17.5
        avatar.clipsToBounds = true
    }
    
    func configureNameLbl() {
        nameLbl = addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightSemibold, textColor: .black)
            .layout({ (mk) in
                mk.left.equalTo(avatar.snp.right).offset(13)
                mk.top.equalTo(avatar)
            })
        nameLbl.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.4
    }
    
    func configureAvatarClub() {
        avatarClubIcon = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.size.equalTo(20)
                mk.left.equalTo(nameLbl.snp.right)
            })
        avatarClubIcon.layer.cornerRadius = 10
        avatarClubIcon.clipsToBounds = true
    }
    
    func configureDistanceLbl() {
        distanceLbl = addSubview(UILabel.self)
            .config(12, textColor: kTextGray54)
            .layout({ (mk) in
                mk.left.equalTo(nameLbl)
                mk.top.equalTo(nameLbl.snp.bottom).offset(3)
            })
    }
    
    func configureOtherStaticMarker() {
//        addSubview(UIImageView.self).config(#imageLiteral(resourceName: "account_btn_next_icon"))
//            .layout { (mk) in
//                mk.centerY.equalToSuperview()
//                mk.right.equalToSuperview().offset(-25)
//                mk.size.equalTo(CGSize(width: 9, height: 15))
//        }
        addSubview(UIView.self).config(UIColor(white: 0.945, alpha: 1))
            .layout { (mk) in
                mk.left.equalToSuperview()
                mk.right.equalToSuperview()
                mk.bottom.equalToSuperview()
                mk.height.equalTo(0.5)
        }
    }
    
    var fontForAvatarCarName = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)

    func configureAvatarCar() {
        avatarCarNameLbl = addSubview(UILabel.self)
            .layout({ (mk) in
                mk.right.equalToSuperview().offset(-15)
                mk.centerY.equalToSuperview()
            })
        avatarCarNameLbl.font = fontForAvatarCarName
        avatarCarNameLbl.textColor = kTextGray54
        avatarCarNameLbl.textAlignment = .right
        avatarCarNameLbl.numberOfLines = 2
        avatarCarNameLbl.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.4
        
        avatarCarLogoIcon = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.centerY.equalTo(avatarCarNameLbl)
                mk.right.equalTo(avatarCarNameLbl.snp.left)
                mk.size.equalTo(21)
            })
    }
    
    func configureGenderIcon() {
        genderIcon = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(nameLbl.snp.right)
                mk.size.equalTo(15)
            })
        genderIcon.contentMode = .scaleAspectFit
    }
    
    func loadDataAndUpdateUI() {
        avatar.kf.setImage(with: user.avatarURL!)
        if user.identified {
            nameLbl.textColor = kHighlightRed
        } else {
            nameLbl.textColor = .black
        }
        nameLbl.text = user.nickName
        var distance = hostLoc.distance(from: userLoc)
        var showKM = false
        if distance > 1000 {
            distance = distance / 1000
            showKM = true
        }
        distanceLbl.text = LS("距离你  ") + "\(Int(distance))" + (showKM ? "km" : "m")
        if let avatarClub = user.avatarClubModel {
//            avatarClubLogo.kf.setImage(with: avatarClub.logoURL!, for: .normal)
            avatarClubIcon.kf.setImage(with: avatarClub.logoURL!)
            genderIcon.snp.remakeConstraints({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(avatarClubIcon.snp.right).offset(2)
                mk.size.equalTo(15)
            })
        } else {
            avatarClubIcon.isHidden = true
            genderIcon.snp.remakeConstraints({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(nameLbl.snp.right)
                mk.size.equalTo(15)
            })
        }
        
        if let car = user.avatarCarModel {
            avatarCarNameLbl.isHidden = false
            avatarCarLogoIcon.isHidden = false
            avatarCarNameLbl.text = car.name
            avatarCarLogoIcon.kf.setImage(with: car.logoURL!)
        } else {
            avatarCarNameLbl.isHidden = true
            avatarCarLogoIcon.isHidden = true
        }
        
        if user.gender == "m" {
            genderIcon.image = #imageLiteral(resourceName: "gender_mark_male")
        } else {
            genderIcon.image = #imageLiteral(resourceName: "gender_mark_female")
        }
    }
    
}
