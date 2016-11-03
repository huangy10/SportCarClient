//
//  PersonHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol PersonProfileProtocol: class {
    func headerStatusNumPressed()
    func headerFansNumPressed()
    func headerFollowsNumPressed()
    func headerFollowBtnPressed()
}


class PersonProfileView: UIView {
    private var user: User
    weak var delegate: PersonProfileProtocol!
    
    var isHost: Bool {
        return user.isHost
    }
    
    init (user: User) {
        self.user = user
        super.init(frame: .zero)
        
        configureMap()
        configureBackMask()
        configureAvatarBtn()
        configureAvatarCar()
        configureNameLbl()
        configureAvatarClub()
        configureDetailBtn()
        configureNumbersStack()
        configureNumberLbls()
        configureSepLine()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var avatarBtn: UIButton!
    var detailBtn: UIButton!
    var nameLbl: UILabel!
    var avatarCarIcon: UIImageView!
    var avatarCarNameLbl: UILabel!
    var avatarClubIcon: UIImageView!
    var backMask: BackMaskView!
    var numStack: UIStackView!
    var statusNumLbl: UILabel!
    var fansNumLbl: UILabel!
    var followsNumLbl: UILabel!
    var followBtn: UIButton!
    var map: BMKMapView!
    //
    
    let locateYourSelf = true
    
    func configureMap() {
        map = addSubview(BMKMapView.self).config(UIColor.black)
            .layout({ (make) in
                make.edges.equalTo(self).inset(UIEdgeInsetsMake(-300, 0, 0, 0))
            })
    }
    
    func configureBackMask() {
        backMask = BackMaskView()
        backMask.backgroundColor = UIColor.clear
//        backMask.centerHegiht = 175 * scale
        backMask.centerHegiht = 175
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
//                make.top.equalTo(self).offset(140.0 * scale)
                make.bottom.equalTo(self).offset(121)
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
    
    func configureNumberLbls() {
        var lbls: [UILabel] = []
        ["动态", "粉丝", "关注"].enumerated().forEach { (idx, text) in
            let btn = UIButton()
            btn.autoresizingMask = .flexibleHeight
            btn.addTarget(self, action: #selector(numberBtnPresed(sender:)), for: .touchUpInside)
            numStack.addArrangedSubview(btn)
            
            let lbl = btn.addSubview(UILabel.self)
            configure(numberLblsInStack: lbl)
            lbl.snp.makeConstraints({ (mk) in
                mk.centerX.equalTo(btn)
                mk.top.equalTo(btn)
            })
            lbls.append(lbl)
            
            let sLbl = btn.addSubview(UILabel.self)
            configure(staticLblsInStack: sLbl)
            sLbl.text = text
            sLbl.snp.makeConstraints({ (mk) in
                mk.centerX.equalTo(lbl)
                mk.top.equalTo(lbl.snp.bottom).offset(2)
            })
        }
        
        statusNumLbl = lbls[0]
        fansNumLbl = lbls[1]
        followsNumLbl = lbls[2]
    }
    
    func configure(numberLblsInStack lbl: UILabel) {
        if isHost {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightSemibold)
        } else {
            lbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        }
        lbl.textColor = .black
        lbl.textAlignment = .center
    }
    
    func configure(staticLblsInStack lbl: UILabel) {
        lbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        lbl.textColor = kTextGray38
        lbl.textAlignment = .center
    }
    
    func configureNumbersStack() {
        numStack = UIStackView()
        numStack.axis = .horizontal
        numStack.distribution = .fillEqually
        numStack.spacing = 0
        numStack.alignment = .center
        
        addSubview(numStack)
        numStack.snp.makeConstraints { (mk) in
            mk.top.equalTo(avatarBtn.snp.bottom).offset(23)
            if isHost {
                mk.right.equalTo(self).offset(-30)
            } else {
                mk.right.equalTo(self).offset(-30 - 78 - 15)
            }
            mk.left.equalTo(self).offset(30)
            mk.bottom.equalTo(self)
        }
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
    
    func configureFollowBtnPressed() {
        followBtn = addSubview(UIButton.self)
            .layout({ (mk) in
                mk.centerY.equalTo(fansNumLbl.snp.bottom)
                mk.right.equalTo(self).offset(-15)
                mk.width.equalTo(78)
                mk.height.equalTo(25)
            })
        followBtn.layer.cornerRadius = 2
        followBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
    }
    
    func loadDataAndUpdateUI () {
        avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
        if let car = user.avatarCarModel {
            avatarCarIcon.kf.setImage(with: car.logoURL!)
            avatarCarNameLbl.text = car.name
        } else {
            avatarCarIcon.image = nil
            avatarCarNameLbl.text = LS("暂无认证爱车")
        }
        
        if let club = user.avatarClubModel {
            avatarClubIcon.kf.setImage(with: club.logoURL!)
        } else {
            avatarClubIcon.image = nil
        }
        
        nameLbl.text = user.nickName
        
        fansNumLbl.text = "\(user.fansNum)"
        followsNumLbl.text = "\(user.followsNum)"
        statusNumLbl.text = "\(user.statusNum)"
    }
    
    func setFollowState(_ isFollowed: Bool) {
        if isFollowed {
            followBtn.layer.borderColor = UIColor.clear.cgColor
            followBtn.backgroundColor = UIColor(white: 0.96, alpha: 1)
            followBtn.setTitle(LS("已关注"), for: .normal)
            followBtn.setTitleColor(kTextGray38, for: .normal)
        } else {
            followBtn.layer.borderColor = kHighlightRed.cgColor
            followBtn.backgroundColor = UIColor.clear
            followBtn.layer.borderWidth = 1
            followBtn.setTitle(LS("+ 关注"), for: .normal)
            followBtn.setTitleColor(kHighlightRed, for: .normal)
        }
    }
    
    func followBtnPressed() {
        delegate.headerFollowBtnPressed()
    }
    
    func numberBtnPresed(sender: UIButton) {
        switch sender.tag {
        case 0:
            delegate.headerStatusNumPressed()
        case 1:
            delegate.headerFansNumPressed()
        case 2:
            delegate.headerFollowsNumPressed()
        default:
            fatalError()
        }
    }
}
