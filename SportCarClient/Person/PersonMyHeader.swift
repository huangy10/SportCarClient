//
//  PersonMyHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox
import Kingfisher
import SnapKit

class PersonHeaderMine: UIView, MGLMapViewDelegate {
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
    var map: MGLMapView!    // 地图
    
    var navRightBtn: UIButton!      // 单独创建的类似导航栏的按钮，但是并不在导航栏中
    var navLeftBtn: UIButton!       // 同上
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        map = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        map.allowsRotating = false
        map.allowsScrolling = false
        map.delegate = self
        superview.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
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
        avatarCarBtn.backgroundColor = UIColor(white: 0.72, alpha: 1)
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
        superview.addSubview(avatarClubLogo)
        avatarClubLogo.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(nameLbl)
            make.left.equalTo(nameLbl.snp_right).offset(7)
            make.size.equalTo(20)
        }
        //
//        let gender = user.gender!
//        var lblBGColor: UIColor
//        if gender == "m" {
//            lblBGColor = UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1)
//        }else{
//            lblBGColor = kHighlightedRedTextColor
//        }
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
            make.left.equalTo(nameLbl)
            make.top.equalTo(nameLbl)
            make.bottom.equalTo(avatarBtn)
            make.right.equalTo(arrowIcon)
        }
        //
        fansNumLbl = UILabel()
        fansNumLbl.textColor = UIColor.blackColor()
        fansNumLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        fansNumLbl.textAlignment = .Center
        superview.addSubview(fansNumLbl)
        fansNumLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(avatarBtn)
            make.top.equalTo(avatarBtn.snp_bottom).offset(35)
        }
        //
        let staticFansNumLbl = UILabel()
        staticFansNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticFansNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticFansNumLbl.textAlignment = .Center
        staticFansNumLbl.text = LS("粉丝")
        superview.addSubview(staticFansNumLbl)
        staticFansNumLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(fansNumLbl.snp_bottom).offset(2)
            make.centerX.equalTo(fansNumLbl)
        }
        //
        statusNumLbl = UILabel()
        statusNumLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        statusNumLbl.textColor = UIColor.blackColor()
        statusNumLbl.textAlignment = .Center
        superview.addSubview(statusNumLbl)
        statusNumLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(fansNumLbl.snp_left).offset(-50)
            make.centerY.equalTo(fansNumLbl)
        }
        //
        let staticStatusNumLbl = UILabel()
        staticStatusNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticStatusNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticStatusNumLbl.textAlignment = .Center
        staticStatusNumLbl.text = LS("动态")
        superview.addSubview(staticStatusNumLbl)
        staticStatusNumLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(statusNumLbl)
            make.top.equalTo(statusNumLbl.snp_bottom).offset(2)
        }
        //
        followNumLbl = UILabel()
        followNumLbl.textAlignment = .Center
        followNumLbl.textColor = UIColor.blackColor()
        followNumLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        superview.addSubview(followNumLbl)
        followNumLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(fansNumLbl.snp_right).offset(50)
            make.centerY.equalTo(fansNumLbl)
        }
        //
        let staticFollowNumLbl = UILabel()
        staticFollowNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticFollowNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticFollowNumLbl.textAlignment = .Center
        staticFollowNumLbl.text = LS("关注")
        superview.addSubview(staticFollowNumLbl)
        staticFollowNumLbl.snp_makeConstraints { (make) -> Void in
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
        
    }
    
    func loadDataAndUpdateUI() {
        // 头像
        avatarBtn.kf_setImageWithURL(SFURL(user.avatarUrl!)!, forState: .Normal)
        // 认证跑车
        if let avatarCar = user.avatarCar {
            avatarCarBtn.kf_setImageWithURL(SFURL(avatarCar.logo!)!, forState: .Normal)
            avatarCarNameLbl.text = avatarCar.name
        }else {
            avatarCarBtn.setImage(nil, forState: .Normal)
            avatarCarNameLbl.text = ""
        }
        // 
        nameLbl.text = user.nickName
        //
        let genderText = user.gender ?? "m"
        let gender = ["男": "♂", "女": "♀"][genderText]
        if genderText == "m" {
            genderAgeLbl.backgroundColor = UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1)
        }else {
            genderAgeLbl.backgroundColor = UIColor(red: 0.686, green: 0.227, blue: 0.490, alpha: 1)
        }
        let age = user.age
        genderAgeLbl.text = "\(gender!) \(age)"
        // 
        let profile = user.profile
        fansNumLbl.text = "\(profile!.fansNum)"
        followNumLbl.text = "\(profile!.followNum)"
        statusNumLbl.text = "\(profile!.statusNum)"
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
