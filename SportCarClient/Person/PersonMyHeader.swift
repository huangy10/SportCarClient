//
//  PersonMyHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class PersonHeaderMine: UIView {
    // 绑定的相关用户
    var user: User!
    // 
    var avatarBtn: UIButton!
    var detailBtn: UIButton!
    var avatarCarIcon: UIImageView!
    var nameLbl: UILabel!
    var genderAgeLbl: UILabel!
    var avatarCarNameLbl: UILabel!
    var avatarClubIcon: UIImageView!
    var backMask: BackMaskView!
    var statusNumLbl: UILabel!
    var fansNumLbl: UILabel!
    var followNumLbl: UILabel!
    var map: BMKMapView!
    
    var fanslistBtn: UIButton!
    var followlistBtn: UIButton!
    var statuslistBtn: UIButton!
    
    let scale: CGFloat = UIScreen.main.bounds.width / 375.0
    
    /// 是否自己抓取位置数据
    var locateYouself = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        configureMap()
        configureBackMask()
        configureAvatarBtn()
        configureAvatarCar()
        configureNameLbl()
        configureAvatarClub()
        configureDetailBtn()
        configureFansNum()
        configureStatusNum()
        configureFollowNum()
        layoutBottomLbls()
        configureSepLine()
    }
    
    func configureMap() {
        map = addSubview(BMKMapView.self).config(UIColor.black)
            .layout({ (make) in
                make.edges.equalTo(self).inset(UIEdgeInsetsMake(-300, 0, 0, 0))
            })
    }
    
    func configureBackMask() {
        backMask = BackMaskView()
        backMask.backgroundColor = UIColor.clear
        backMask.centerHegiht = 175 * scale
        backMask.ratio = 0.2
        backMask.addShadow(opacity: 0.1, offset: CGSize(width: 0, height: -3))
        addSubview(backMask)
        backMask.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        backMask.setNeedsDisplay()
    }
    
    func configureAvatarBtn() {
        avatarBtn = addSubview(UIButton.self)
            .layout { (make) in
                make.top.equalTo(self).offset(140.0 * scale)
                make.size.equalTo(90)
                make.left.equalTo(self).offset(25)
        }
        avatarBtn.layer.cornerRadius = 45
        avatarBtn.clipsToBounds = true
    }
    
    func configureAvatarCar() {
        avatarCarIcon = addSubview(UIImageView.self)
            .layout({ (make) in
                make.right.equalTo(avatarBtn)
                make.bottom.equalTo(avatarBtn)
                make.size.equalTo(30)
            })
        avatarCarIcon.contentMode = .scaleAspectFit
        avatarCarIcon.layer.cornerRadius = 15
        
        avatarCarNameLbl = addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.58))
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(14)
                make.centerY.equalTo(avatarCarIcon)
            })
    }
    
    func configureNameLbl() {
        nameLbl = addSubview(UILabel.self)
            .config(16, fontWeight: UIFontWeightSemibold, textColor: UIColor.black)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(14)
                make.centerY.equalTo(avatarBtn).offset(-3)
            })
    }
    
    func configureAvatarClub() {
        avatarClubIcon = addSubview(UIImageView.self)
            .layout({ (make) in
                make.centerY.equalTo(nameLbl)
                make.left.equalTo(nameLbl.snp.right).offset(10)
                make.size.equalTo(20)
            })
        avatarClubIcon.layer.cornerRadius = 10
        avatarClubIcon.clipsToBounds = true
    }
    
    func configureDetailBtn() {
        let arrowRightIcon = addSubview(UIImageView.self)
            .config(UIImage(named: "account_btn_next_icon"))
            .layout { (make) in
                make.right.equalTo(self).offset(-12)
                make.centerY.equalTo(nameLbl)
                make.size.equalTo(10)
        }
        arrowRightIcon.contentMode = .scaleAspectFit
        
        _ = addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray54, textAlignment: .right, text: LS("详细信息"))
            .layout({ (make) in
                make.centerY.equalTo(arrowRightIcon)
                make.right.equalTo(arrowRightIcon.snp.left).offset(-7)
            })
        
        detailBtn = addSubview(UIButton.self)
            .layout({ (make) in
                make.left.equalTo(avatarBtn)
                make.bottom.equalTo(avatarBtn)
                make.top.equalTo(avatarBtn)
                make.right.equalTo(arrowRightIcon)
            })
    }
    
    func configureFansNum() {
        fansNumLbl = addSubview(UILabel.self)
//            .layout({ (make) in
//                make.centerX.equalTo(self)
//                make.top.equalTo(avatarBtn.snp.bottom).offset(23)
//            })
        setAppearance(ofBottomLbls: fansNumLbl)
        setAppearance(ofBottomStaticLabel: addSubview(UILabel.self).layout { (make) in
            make.centerX.equalTo(fansNumLbl)
            make.top.equalTo(fansNumLbl.snp.bottom).offset(2)
            }, withText: LS("粉丝"))
        fanslistBtn = addSubview(UIButton.self)
            .layout({ (make) in
                make.top.equalTo(fansNumLbl)
                make.centerX.equalTo(fansNumLbl)
                make.size.equalTo(44)
            })
    }
    
    func configureStatusNum() {
        statusNumLbl = addSubview(UILabel.self)
//            .layout({ (make) in
//                make.centerX.equalTo(fansNumLbl).offset(-90)
//                make.centerY.equalTo(fansNumLbl)
//            })
        setAppearance(ofBottomLbls: statusNumLbl)
        setAppearance(ofBottomStaticLabel: addSubview(UILabel.self).layout({ (make) in
            make.centerX.equalTo(statusNumLbl)
            make.top.equalTo(statusNumLbl.snp.bottom).offset(2)
        }), withText: LS("动态"))
        statuslistBtn = addSubview(UIButton.self)
            .layout({ (make) in
                make.top.equalTo(statusNumLbl)
                make.centerX.equalTo(statusNumLbl)
                make.size.equalTo(44)
            })
    }
    
    func configureFollowNum() {
        followNumLbl = addSubview(UILabel.self)
//            .layout({ (make) in
//                make.centerX.equalTo(fansNumLbl).offset(90)
//                make.centerY.equalTo(fansNumLbl)
//            })
        setAppearance(ofBottomLbls: followNumLbl)
        setAppearance(ofBottomStaticLabel: addSubview(UILabel.self).layout({ (make) in
            make.centerX.equalTo(followNumLbl)
            make.top.equalTo(followNumLbl.snp.bottom).offset(2)
        }), withText: LS("关注"))
        followlistBtn = addSubview(UIButton.self)
            .layout({ (make) in
                make.top.equalTo(followNumLbl)
                make.centerX.equalTo(followNumLbl)
                make.size.equalTo(44)
            })
    }
    
    func layoutBottomLbls() {
        fansNumLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(avatarBtn.snp.bottom).offset(23)
        }
        statusNumLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(fansNumLbl).offset(-90)
            make.centerY.equalTo(fansNumLbl)
        }
        followNumLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(fansNumLbl).offset(90)
            make.centerY.equalTo(fansNumLbl)
        }
    }
    
    func setAppearance(ofBottomLbls label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightSemibold)
        label.textColor = UIColor.black
        label.textAlignment = .center
    }
    
    func setAppearance(ofBottomStaticLabel label: UILabel, withText text: String) {
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        label.textColor = UIColor(white: 0, alpha: 0.38)
        label.textAlignment = .center
        label.text = text
    }
    
    func configureSepLine() {
        addSubview(UIView.self).config(UIColor(white: 0, alpha: 0.12))
            .layout { (make) in
                make.bottom.equalTo(self)
                make.left.equalTo(self).offset(12)
                make.right.equalTo(self).offset(-12)
                make.height.equalTo(0.5)
        }
    }
    
    func loadDataAndUpdateUI() {
        // 头像
        avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
        // 认证跑车
        if let car = user.avatarCarModel {
//            avatarCarBtn.kf.setImage(with: car.logoURL!, for: .normal)
            avatarCarIcon.kf.setImage(with: car.logoURL!)
            avatarCarNameLbl.text = car.name
        } else {
//            avatarCarBtn.setImage(nil, for: .normal)
            avatarCarIcon.image = nil
            avatarCarNameLbl.text = LS("暂无认证爱车")
        }
        // 认证俱乐部
        if let club = user.avatarClubModel {
//            avatarClubLogo.kf.setImage(with: club.logoURL!, for: .normal)
            avatarClubIcon.kf.setImage(with: club.logoURL!)
        }else {
            avatarClubIcon.image = nil
        }
        // 
        nameLbl.text = user.nickName
        //
        fansNumLbl.text = "\(user.fansNum)"
        followNumLbl.text = "\(user.followsNum)"
        statusNumLbl.text = "\(user.statusNum)"
    }
}


class BackMaskView: UIView {
    var ratio: CGFloat = 0.1
    var centerHegiht : CGFloat = 100
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        let width = self.frame.width
        let height = self.frame.height
        ctx?.saveGState()
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.move(to: CGPoint(x: 0, y: height))
        ctx?.addLine(to: CGPoint(x: width, y: height))
        let rightHeight = centerHegiht + width * ratio / 2
        let leftHeight = centerHegiht - width * ratio / 2
        ctx?.addLine(to: CGPoint(x: width, y: height - rightHeight))
        ctx?.addLine(to: CGPoint(x: 0, y: height - leftHeight))
        ctx?.closePath()
        ctx?.fillPath()
        ctx?.restoreGState()
    }
}
