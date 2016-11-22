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
                mk.left.equalTo(nameLbl.snp.right).offset(10)
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
                mk.right.equalTo(avatarCarNameLbl.snp.left).offset(-2)
                mk.size.equalTo(20)
            })
        avatarCarLogoIcon.layer.cornerRadius = 10
        avatarCarLogoIcon.clipsToBounds = true
    }
    
    func configureGenderIcon() {
        genderIcon = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(nameLbl.snp.right).offset(10)
                mk.size.equalTo(12)
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
        updateDistanceLbl()
        if let avatarClub = user.avatarClubModel {
            avatarClubIcon.kf.setImage(with: avatarClub.logoURL!)
            genderIcon.snp.remakeConstraints({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(avatarClubIcon.snp.right).offset(5)
                mk.size.equalTo(12)
            })
        } else {
            avatarClubIcon.image = nil
            genderIcon.snp.remakeConstraints({ (mk) in
                mk.centerY.equalTo(nameLbl)
                mk.left.equalTo(nameLbl.snp.right).offset(10)
                mk.size.equalTo(12)
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
        
        if user.gender == "男" {
            genderIcon.image = #imageLiteral(resourceName: "gender_mark_male")
        } else if user.gender == "女" {
            genderIcon.image = #imageLiteral(resourceName: "gender_mark_female")
        } else {
            genderIcon.image = nil
        }
    }
    
    func updateDistanceLbl() {
        var distance = hostLoc.distance(from: userLoc)
        var showKM = false
        if distance > 1000 {
            distance = distance / 1000
            showKM = true
        }
        distanceLbl.text = LS("距离你  ") + "\(Int(distance))" + (showKM ? "km" : "m")
    }
}
