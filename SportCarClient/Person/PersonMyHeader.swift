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
    
    var navRightBtn: UIButton!      // 单独创建的类似导航栏的按钮，但是并不在导航栏中
    var navLeftBtn: UIButton!       // 同上
    
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
        map = BMKMapView()
        map.backgroundColor = UIColor.blackColor()
        superview.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview).inset(UIEdgeInsetsMake(-300, 0, 0, 0))
        }
        //
        backMask = BackMaskView()
        backMask.backgroundColor = UIColor.clearColor()
        backMask.centerHegiht = 175
        backMask.ratio = 0.2
        superview.addSubview(backMask)
        backMask.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(300)
        }
        backMask.setNeedsDisplay()
        //
        avatarBtn = UIButton()
        avatarBtn.backgroundColor = UIColor(white: 0.72, alpha: 1)
        avatarBtn.layer.cornerRadius = 62.5
        avatarBtn.clipsToBounds = true
        superview.addSubview(avatarBtn)
        avatarBtn.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(-100)
            make.centerX.equalTo(superview)
            make.size.equalTo(125)
        }
        //
        avatarCarBtn = UIButton()
        avatarCarBtn.layer.cornerRadius = 16.5
//        avatarCarBtn.backgroundColor = UIColor(white: 0.72, alpha: 1)
        avatarCarBtn.imageView?.layer.cornerRadius = 16.5
        avatarCarBtn.imageView?.contentMode = .ScaleAspectFit
        superview.addSubview(avatarCarBtn)
        avatarCarBtn.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(avatarBtn)
            make.right.equalTo(avatarBtn)
            make.size.equalTo(33)
        }
        //
        nameLbl = UILabel()
        nameLbl.font = UIFont.systemFontOfSize(19, weight: UIFontWeightUltraLight)
        nameLbl.textColor = UIColor.blackColor()
        superview.addSubview(nameLbl)
        nameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp_right).offset(15)
            make.centerY.equalTo(avatarBtn).offset(-5)
        }
        //
        avatarClubLogo = UIButton()
        avatarClubLogo.layer.cornerRadius = 10
        avatarClubLogo.clipsToBounds = true
        superview.addSubview(avatarClubLogo)
        avatarClubLogo.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(nameLbl)
            make.left.equalTo(nameLbl.snp_right).offset(7)
            make.size.equalTo(20)
        }
        //
        genderAgeLbl = UILabel()
        genderAgeLbl.backgroundColor = UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1)
        genderAgeLbl.textColor = UIColor.whiteColor()
        genderAgeLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(genderAgeLbl)
        genderAgeLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLbl)
            make.top.equalTo(nameLbl.snp_bottom).offset(5)
        }
        //
        let arrowIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrowIcon)
        arrowIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSizeMake(9, 15))
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(genderAgeLbl).offset(2)
        }
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        avatarCarNameLbl.textColor = UIColor.blackColor()
        superview.addSubview(avatarCarNameLbl)
        avatarCarNameLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(genderAgeLbl.snp_bottom).offset(12)
            make.left.equalTo(genderAgeLbl)
        }
        //
        detailBtn = UIButton()
        superview.addSubview(detailBtn)
        detailBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn)
            make.top.equalTo(nameLbl)
            make.bottom.equalTo(avatarBtn)
            make.right.equalTo(arrowIcon)
        }
        //
        fansNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .Center)
            .layout({ (make) in
                make.centerX.equalTo(avatarBtn)
                make.top.equalTo(avatarBtn.snp_bottom).offset(35)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("粉丝"))
            .layout { (make) in
                make.top.equalTo(fansNumLbl.snp_bottom).offset(2)
                make.centerX.equalTo(fansNumLbl)
        }
        //
        statusNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .Center)
            .layout({ (make) in
                make.centerX.equalTo(fansNumLbl).offset(-85)
                make.centerY.equalTo(fansNumLbl)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("动态"))
            .layout { (make) in
                make.centerX.equalTo(statusNumLbl)
                make.top.equalTo(statusNumLbl.snp_bottom).offset(2)
        }
        //
        followNumLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, textAlignment: .Center)
            .layout({ (make) in
                make.centerX.equalTo(fansNumLbl).offset(85)
                make.centerY.equalTo(fansNumLbl)
            })
        //
        superview.addSubview(UILabel.self)
            .config(15, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("关注"))
            .layout { (make) in
                make.centerX.equalTo(followNumLbl)
                make.top.equalTo(followNumLbl.snp_bottom).offset(2)
        }
        // 
        navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
        navLeftBtn.imageEdgeInsets = UIEdgeInsetsMake(16, 15, 16, 15)
        superview.addSubview(navLeftBtn)
        navLeftBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.centerY.equalTo(superview.snp_top).offset(40)
            make.size.equalTo(44)
        }
        //
        navRightBtn = UIButton()
        superview.addSubview(navRightBtn)
        navRightBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.centerY.equalTo(superview.snp_top).offset(40)
            make.size.equalTo(44)
        }
        let icon = UIImageView(image: UIImage(named: "person_setting"))
        navRightBtn.addSubview(icon)
        icon.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(navRightBtn)
            make.size.equalTo(20)
        }
        // 在粉丝和关注上方加一个透明按钮以实现点击进入粉丝列表
        fanslistBtn = UIButton()
        superview.addSubview(fanslistBtn)
        fanslistBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(fansNumLbl)
            make.top.equalTo(fansNumLbl)
            make.size.equalTo(44)
        }
        //
        followlistBtn = UIButton()
        superview.addSubview(followlistBtn)
        followlistBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(followNumLbl)
            make.top.equalTo(followNumLbl)
            make.size.equalTo(44)
        }
        //
        statuslistBtn = UIButton()
        superview.addSubview(statuslistBtn)
        statuslistBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(statusNumLbl)
            make.top.equalTo(statusNumLbl)
            make.size.equalTo(44)
        }
    }
    
    func loadDataAndUpdateUI() {
        // 头像
        avatarBtn.kf_setImageWithURL(user.avatarURL!, forState: .Normal)
        // 认证跑车
        if let car = user.avatarCarModel {
            avatarCarBtn.kf_setImageWithURL(car.logoURL!, forState: .Normal)
            avatarCarNameLbl.text = car.name
        } else {
            avatarCarBtn.setImage(nil, forState: .Normal)
            avatarCarNameLbl.text = ""
        }
        // 认证俱乐部
        if let club = user.avatarClubModel {
            avatarClubLogo.kf_setImageWithURL(club.logoURL!, forState: .Normal)
        }else {
            avatarClubLogo.setImage(nil, forState: .Normal)
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let ctx = UIGraphicsGetCurrentContext()
        let width = self.frame.width
        let height = self.frame.height
        CGContextSaveGState(ctx)
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextMoveToPoint(ctx, 0, height)
        CGContextAddLineToPoint(ctx, width, height)
        let rightHeight = centerHegiht + width * ratio / 2
        let leftHeight = centerHegiht - width * ratio / 2
        CGContextAddLineToPoint(ctx, width, height - rightHeight)
        CGContextAddLineToPoint(ctx, 0, height - leftHeight)
        CGContextClosePath(ctx)
        CGContextFillPath(ctx)
        CGContextRestoreGState(ctx)
    }
}
