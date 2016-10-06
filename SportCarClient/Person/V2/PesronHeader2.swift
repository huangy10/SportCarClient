//
//  PesronHeader2.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol PersonHeaderDataSource: class {
    
}

protocol PersonHeaderDelegate: class {
    
    func personHeaderStatusListPressed(header: PersonHeader)
    
    func personHeaderGetContainer() -> UIViewController
    
    func shouldStartNetworkActivity() -> Bool
    
    func didFinisheNetworkActivity()
}


class PersonHeader: UICollectionReusableView {
    
    static let requiredHeight: CGFloat = 328
    fileprivate var user: User
    
    weak var dataSource: PersonHeaderDataSource?
    weak var delegate: PersonHeaderDelegate?
    
    static func initWith(user: User) -> PersonHeader {
        if user.isHost {
            return PersonHeader(user: user)
        } else {
            return PersonOtherHeader(user: user)
        }
    }
    
    fileprivate init (user: User) {
        self.user = user
        super.init(frame: CGRect.zero)
        
        createSubviews()
    }
    
    init() {
        fatalError("User initWith(user:) instead")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var avatarBtn: UIButton!
    var detailBtn: UIButton!
    var nameLbl: UILabel!
    var avatarCarIcon: UIImageView!
    var avatarCarNameLbl: UILabel!
    var avatarClubIcon: UIImageView!
    var backMask: BackMaskView!
    var statusNumLbl: UILabel!
    var fansNumLbl: UILabel!
    var followsNumLbl: UILabel!
    var map: BMKMapView!
    
    var fansListBtn: UIButton!
    var followsListBtn: UIButton!
    var statusListBtn: UIButton!
    
    var locateYourself = true
    
    let intervalBetweenHorizontalLabels: CGFloat = 80
    
    func createSubviews() {
        configureMap()
        configureBackMask()
        configureAvatarBtn()
        configureAvatarCar()
        configureNameLbl()
        configureAvatarClubIcon()
        configureDetailBtn()
        configureFansNumLbl()
        configureStatusNumLbl()
        configureFollowsNumLbl()
        configureBottomSepLine()
        
        reload()
    }
    
    // 
    func configureMap() {
        map = addSubview(BMKMapView.self).config(UIColor.black)
            .layout({ (make) in
                make.edges.equalTo(self).inset(UIEdgeInsetsMake(-300, 0, 0, 0))
            })
    }
    
    func configureBackMask() {
        backMask = BackMaskView()
        backMask.backgroundColor = UIColor.clear
        backMask.centerHegiht = 176
        backMask.ratio = 0.2
        backMask.addShadow(opacity: 0.1, offset: CGSize(width: 0, height: -3))
        addSubview(backMask)
        backMask.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func configureAvatarBtn() {
        avatarBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(avatarBtnPressed))
            .layout({ (make) in
                make.left.equalTo(self).offset(25)
                make.bottom.equalTo(self).offset(-100)
                make.size.equalTo(90)
            })
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
        avatarCarIcon.layer.cornerRadius = 15
        avatarCarIcon.contentMode = .scaleAspectFit
        
        avatarCarNameLbl = addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0, alpha: 54))
            .layout({ (make) in
                make.left.equalTo(avatarCarIcon.snp.right).offset(12)
                make.centerY.equalTo(avatarCarIcon)
            })
    }
    
    func configureNameLbl() {
        nameLbl = addSubview(UILabel.self)
            .config(16, fontWeight: UIFontWeightBold, textColor: UIColor.black)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(12)
                make.bottom.equalTo(avatarBtn.snp.centerY).offset(-2)
            })
    }
    
    func configureAvatarClubIcon() {
        avatarClubIcon = addSubview(UIImageView.self)
            .layout({ (make) in
                make.left.equalTo(nameLbl.snp.right).offset(10)
                make.top.equalTo(nameLbl)
                make.size.equalTo(20)
            })
        avatarClubIcon.contentMode = .scaleAspectFit
        avatarClubIcon.layer.cornerRadius = 10
        avatarClubIcon.clipsToBounds = true
    }
    
    func configureDetailBtn() {
        let rightArrowIcon = addSubview(UIImageView.self)
            .config(UIImage(named: "account_btn_next_icon"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.right.equalTo(self).offset(-12)
                make.width.equalTo(9)
                make.height.equalTo(15)
                make.centerY.equalTo(nameLbl)
        }
        
        _ = addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .right, text: LS("详细信息"))
            .layout { (make) in
                make.right.equalTo(rightArrowIcon.snp.left).offset(-7)
                make.centerY.equalTo(rightArrowIcon)
        }
        
        detailBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(detailBtnPressed))
            .layout({ (make) in
                make.left.equalTo(avatarBtn)
                make.top.equalTo(avatarBtn)
                make.bottom.equalTo(avatarBtn)
                make.right.equalTo(rightArrowIcon)
            })
    }
    
    func configureFansNumLbl() {
        fansNumLbl = addSubview(UILabel.self)
            .layout({ (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(avatarBtn.snp.bottom).offset(32)
            })
        setAppearanceOf(bottomNumberLabel: fansNumLbl)
        
        let t = addSubview(UILabel.self)
            .layout { (make) in
                make.centerX.equalTo(fansNumLbl)
                make.top.equalTo(fansNumLbl.snp.bottom).offset(7)
        }
        setAppearanceOf(bottomStaticLabel: t, withText: LS("粉丝"))
        
        fansListBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(fansListBtnPressed))
            .layout({ (make) in
                make.left.equalTo(fansNumLbl)
                make.right.equalTo(fansNumLbl)
                make.top.equalTo(fansNumLbl)
                make.bottom.equalTo(t)
            })
    }
    
    func configureStatusNumLbl() {
        statusNumLbl = addSubview(UILabel.self)
            .layout({ (make) in
                make.centerY.equalTo(fansNumLbl)
                make.centerX.equalTo(fansNumLbl).offset(-intervalBetweenHorizontalLabels)
            })
        setAppearanceOf(bottomNumberLabel: statusNumLbl)
        
        let t = addSubview(UILabel.self)
            .layout { (make) in
                make.centerX.equalTo(statusNumLbl)
                make.top.equalTo(statusNumLbl.snp.bottom).offset(7)
        }
        setAppearanceOf(bottomStaticLabel: t, withText: LS("动态"))
        
        statusListBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(statusListBtnPressed))
            .layout({ (make) in
                make.left.equalTo(statusNumLbl)
                make.right.equalTo(statusNumLbl)
                make.top.equalTo(statusNumLbl)
                make.bottom.equalTo(t)
            })
    }
    
    func configureFollowsNumLbl() {
        followsNumLbl = addSubview(UILabel.self)
            .layout({ (make) in
                make.centerY.equalTo(fansNumLbl)
                make.centerX.equalTo(fansNumLbl).offset(intervalBetweenHorizontalLabels)
            })
        setAppearanceOf(bottomNumberLabel: followsNumLbl)
        
        let t = addSubview(UILabel.self)
            .layout { (make) in
                make.centerX.equalTo(followsNumLbl)
                make.top.equalTo(followsNumLbl.snp.bottom).offset(7)
        }
        setAppearanceOf(bottomStaticLabel: t, withText: LS("关注"))
        
        followsListBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(followsListBtnPressed))
            .layout({ (make) in
                make.left.equalTo(followsNumLbl)
                make.right.equalTo(followsNumLbl)
                make.top.equalTo(followsNumLbl)
                make.bottom.equalTo(t)
            })
    }
    
    func configureBottomSepLine() {
        addSubview(UIView.self)
            .config(UIColor(white: 0, alpha: 0.12))
            .layout { (make) in
                make.left.equalTo(self).offset(15)
                make.right.equalTo(self).offset(-15)
                make.bottom.equalTo(self)
                make.height.equalTo(0.5)
        }
    }
    
    func setAppearanceOf(bottomNumberLabel label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold)
        label.textColor = UIColor.black
        label.textAlignment = .center
    }
    
    func setAppearanceOf(bottomStaticLabel label: UILabel, withText text: String) {
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        label.textColor = UIColor(white: 0, alpha: 0.38)
        label.textAlignment = .center
        label.text = text
    }
    
    func avatarBtnPressed() {
        
    }
    
    func detailBtnPressed() {
        
    }
    
    func fansListBtnPressed() {
        
    }
    
    func followsListBtnPressed() {
        
    }
    
    func statusListBtnPressed() {
        
    }
    
    func reload() {
        avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
        nameLbl.text = user.nickName
        if let avatarCar = user.avatarCarModel {
            avatarCarIcon.kf.setImage(with: avatarCar.logoURL!)
            avatarCarNameLbl.text = avatarCar.name
        } else {
            avatarCarIcon.image = nil
            avatarCarNameLbl.text = LS("暂无认证爱车")
        }
        
        if let avatarClub = user.avatarClubModel {
            avatarClubIcon.kf.setImage(with: avatarClub.logoURL!)
        } else {
            avatarClubIcon.image = nil
        }
        
        statusNumLbl.text = "\(user.statusNum)"
        fansNumLbl.text = "\(user.fansNum)"
        followsNumLbl.text = "\(user.followsNum)"
    }
}

class PersonOtherHeader: PersonHeader {
    var followBtn: UIButton!
    
    var isFollowed: Bool {
        return user.followed
    }
    
    override func createSubviews() {
        super.createSubviews()
        
        configureFollowBtn()
    }
    
    override func configureFansNumLbl() {
        super.configureFansNumLbl()
        
        fansNumLbl.snp.remakeConstraints { (make) in
            make.centerX.equalTo(nameLbl.snp.left)
            make.top.equalTo(avatarBtn.snp.bottom).offset(32)
        }
    }
    
    func configureFollowBtn() {
        followBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(followBtnPressed))
            .layout({ (make) in
                make.right.equalTo(self).offset(-12)
                make.centerY.equalTo(fansNumLbl.snp.bottom)
                make.width.equalTo(78)
                make.height.equalTo(25)
            })
    }
    
    func setFollowBtnTitle(followed: Bool) {
        if followed {
            followBtn.backgroundColor = UIColor(white: 0.96, alpha: 1)
            followBtn.setTitleColor(UIColor(white: 0, alpha: 0.38), for: .normal)
            followBtn.layer.borderColor = nil
        } else {
            followBtn.backgroundColor = UIColor.clear
            followBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
            followBtn.layer.borderColor = kHighlightedRedTextColor.cgColor
            followBtn.layer.borderWidth = 0.5
            followBtn.setTitle(LS("+ 关注"), for: .normal)
        }
    }
    
    override func reload() {
        super.reload()
        setFollowBtnTitle(followed: isFollowed)
    }
    
    func followBtnPressed() {
        
    }
}
