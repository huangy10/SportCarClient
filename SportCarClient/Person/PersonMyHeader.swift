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
    var avatarCarBtn: UIButton!
    var nameLbl: UILabel!
    var genderAgeLbl: UILabel!
    var avatarCarNameLbl: UILabel!
    var avatarClubLogo: UIButton!
    var backMask: BackMaskView!
    var statusNumLbl: UILabel!
    var fansNumLbl: UILabel!
    var followNumLbl: UILabel!
    var map: BMKMapView!
    
    var fanslistBtn: UIButton!
    var followlistBtn: UIButton!
    var statuslistBtn: UIButton!
    
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
        let superview = self
        map = superview.addSubview(BMKMapView.self).config(UIColor.black)
            .layout({ (make) in
                make.edges.equalTo(superview).inset(UIEdgeInsetsMake(-300, 0, 0, 0))
            })
        //
        backMask = BackMaskView()
        backMask.backgroundColor = UIColor.clear
        backMask.centerHegiht = 175
        backMask.ratio = 0.2
        backMask.addShadow(opacity: 0.1, offset: CGSize(width: 0, height: -3))
        superview.addSubview(backMask)
        backMask.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
//            make.height.equalTo(225)
            make.top.equalTo(superview)
        }
        backMask.setNeedsDisplay()
        //
        avatarBtn = UIButton()
        avatarBtn.layer.cornerRadius = 62.5
        avatarBtn.clipsToBounds = true
        superview.addSubview(avatarBtn)
        avatarBtn.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(-100)
            make.centerX.equalTo(superview)
            make.size.equalTo(125)
        }
        //
        avatarCarBtn = UIButton()
        avatarCarBtn.layer.cornerRadius = 16.5
//        avatarCarBtn.backgroundColor = UIColor(white: 0.72, alpha: 1)
        avatarCarBtn.imageView?.layer.cornerRadius = 16.5
        avatarCarBtn.imageView?.contentMode = .scaleAspectFit
        superview.addSubview(avatarCarBtn)
        avatarCarBtn.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(avatarBtn)
            make.right.equalTo(avatarBtn)
            make.size.equalTo(33)
        }
        //
        nameLbl = UILabel()
        nameLbl.font = UIFont.systemFont(ofSize: 19, weight: UIFontWeightUltraLight)
        nameLbl.textColor = UIColor.black
        superview.addSubview(nameLbl)
        nameLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp.right).offset(15)
            make.centerY.equalTo(avatarBtn).offset(-5)
        }
        //
        avatarClubLogo = UIButton()
        avatarClubLogo.layer.cornerRadius = 10
        avatarClubLogo.clipsToBounds = true
        superview.addSubview(avatarClubLogo)
        avatarClubLogo.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(nameLbl)
            make.left.equalTo(nameLbl.snp.right).offset(7)
            make.size.equalTo(20)
        }
        //
        genderAgeLbl = UILabel()
        genderAgeLbl.backgroundColor = UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1)
        genderAgeLbl.textColor = UIColor.white
        genderAgeLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(genderAgeLbl)
        genderAgeLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(nameLbl)
            make.top.equalTo(nameLbl.snp.bottom).offset(5)
        }
        //
        let arrowIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 9, height: 15))
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(genderAgeLbl).offset(2)
        }
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        avatarCarNameLbl.textColor = UIColor.black
        superview.addSubview(avatarCarNameLbl)
        avatarCarNameLbl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genderAgeLbl.snp.bottom).offset(12)
            make.left.equalTo(genderAgeLbl)
        }
        //
        detailBtn = UIButton()
        superview.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn)
            make.top.equalTo(nameLbl)
            make.bottom.equalTo(avatarBtn)
            make.right.equalTo(arrowIcon)
        }
        //
        fansNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .center)
            .layout({ (make) in
                make.centerX.equalTo(avatarBtn)
                make.top.equalTo(avatarBtn.snp.bottom).offset(35)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .center, text: LS("粉丝"))
            .layout { (make) in
                make.top.equalTo(fansNumLbl.snp.bottom).offset(2)
                make.centerX.equalTo(fansNumLbl)
        }
        //
        statusNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .center)
            .layout({ (make) in
                make.centerX.equalTo(fansNumLbl).offset(-85)
                make.centerY.equalTo(fansNumLbl)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .center, text: LS("动态"))
            .layout { (make) in
                make.centerX.equalTo(statusNumLbl)
                make.top.equalTo(statusNumLbl.snp.bottom).offset(2)
        }
        //
        followNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .center)
            .layout({ (make) in
                make.centerX.equalTo(fansNumLbl).offset(85)
                make.centerY.equalTo(fansNumLbl)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .center, text: LS("关注"))
            .layout { (make) in
                make.centerX.equalTo(followNumLbl)
                make.top.equalTo(followNumLbl.snp.bottom).offset(2)
        }
        // 在粉丝和关注上方加一个透明按钮以实现点击进入粉丝列表
        fanslistBtn = UIButton()
        superview.addSubview(fanslistBtn)
        fanslistBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(fansNumLbl)
            make.top.equalTo(fansNumLbl)
            make.size.equalTo(44)
        }
        //
        followlistBtn = UIButton()
        superview.addSubview(followlistBtn)
        followlistBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(followNumLbl)
            make.top.equalTo(followNumLbl)
            make.size.equalTo(44)
        }
        //
        statuslistBtn = UIButton()
        superview.addSubview(statuslistBtn)
        statuslistBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(statusNumLbl)
            make.top.equalTo(statusNumLbl)
            make.size.equalTo(44)
        }
    }
    
    func loadDataAndUpdateUI() {
        // 头像
        avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
        // 认证跑车
        if let car = user.avatarCarModel {
            avatarCarBtn.kf.setImage(with: car.logoURL!, for: .normal)
            avatarCarNameLbl.text = car.name
        } else {
            avatarCarBtn.setImage(nil, for: UIControlState())
            avatarCarNameLbl.text = ""
        }
        // 认证俱乐部
        if let club = user.avatarClubModel {
            avatarClubLogo.kf.setImage(with: club.logoURL!, for: .normal)
        }else {
            avatarClubLogo.setImage(nil, for: UIControlState())
        }
        // 
        nameLbl.text = user.nickName
        //
        let genderText = user.gender ?? "女"
        let gender = ["男": "♂", "女": "♀"][genderText]
        if genderText == "男" {
            genderAgeLbl.backgroundColor = UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1)
        }else {
            genderAgeLbl.backgroundColor = UIColor(red: 0.686, green: 0.227, blue: 0.490, alpha: 1)
        }
        let age = user.age
        genderAgeLbl.text = "\(gender!) \(age) "
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
