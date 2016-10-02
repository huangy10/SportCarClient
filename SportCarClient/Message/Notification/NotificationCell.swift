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
    
    var readDot: UIView!
    
    var onAvatarPressed: (()->())?
    var notification: Notification!
    weak var navigationController: UINavigationController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.white
        //
        avatarBtn = UIButton()
        avatarBtn.layer.cornerRadius = 22.5
        avatarBtn.clipsToBounds = true
        avatarBtn.addTarget(self, action: #selector(avatarPressed), for: .touchUpInside)
//        avatarBtn.userInteractionEnabled = false
        superview.addSubview(avatarBtn)
        avatarBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(superview).offset(15)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(45)
        }
        //
        nickNameLbl = UILabel()
        nickNameLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBlack)
        nickNameLbl.textColor = UIColor.black
        superview.addSubview(nickNameLbl)
        nickNameLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp.right).offset(15)
            make.bottom.equalTo(avatarBtn.snp.centerY)
        }
        //
        informLbL = UILabel()
        informLbL.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        informLbL.textColor = kNotificationHintColor
        superview.addSubview(informLbL)
        informLbL.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl.snp.right).offset(10)
            make.bottom.equalTo(nickNameLbl)
        }
        //
        dateLbl = UILabel()
        dateLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightUltraLight)
        dateLbl.textColor = kNotificationHintColor
        superview.addSubview(dateLbl)
        dateLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl)
            make.top.equalTo(nickNameLbl.snp.bottom).offset(5)
        }
        
        readDot = superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
            .toRound(5).layout({ (make) in
                make.centerX.equalTo(superview.snp.right).offset(-15)
                make.centerY.equalTo(avatarBtn.snp.top)
                make.size.equalTo(10)
            })
    }
    
    func avatarPressed() {
        if let user = notification.user, let nav = navigationController {
            if user.isHost {
                let detail = PersonBasicController(user: user)
                nav.pushViewController(detail, animated: true)
            } else {
                let detail = PersonOtherController(user: user)
                nav.pushViewController(detail, animated: true)
            }
        } else {
            assertionFailure()
        }
    }
    
    func makeTitleString(_ eles: String...) {
        
    }
}


class NotificationCellWithCoverThumbnail: NotificationBaseCell {
    
    override class func reuseIdentifier() -> String {
        return "notification_cell_with_cover_thumbnail"
    }
    
    var cover: UIImageView!
    var messageBodyLbl: UILabel!
    static let messageBodyLblMaxWidth = UIScreen.main.bounds.width - 30
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        
        cover = UIImageView()
        superview.addSubview(cover)
        cover.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(avatarBtn)
            make.height.equalTo(avatarBtn)
            make.width.equalTo(avatarBtn)
        }
        
        messageBodyLbl = UILabel()
        messageBodyLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        messageBodyLbl.textColor = kNotificationHintColor
        superview.addSubview(messageBodyLbl)
        messageBodyLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn)
            make.right.equalTo(cover)
            make.top.equalTo(avatarBtn.snp.bottom).offset(15)
        }
        
        superview.bringSubview(toFront: readDot)
    }
}


class NotificationCellAboutActivity: NotificationBaseCell{
    
    override class func reuseIdentifier() -> String {
        return "notification_cell_about_activity"
    }
    
    var name2LbL: UILabel!
    var inform2Lbl: UILabel!
    
    var agreenBtn: UIButton!
    var onAgreeBtnPressed: ((_ sender: NotificationCellAboutActivity)->())?
    var denyBtn: UIButton!
    var onDenyBtnPressed: ((_ sender: NotificationCellAboutActivity)->())?
    var doneLbl : UILabel!
    
    var showBtns: Bool = true {
        didSet {
            agreenBtn.isHidden = !showBtns
            denyBtn.isHidden = !showBtns
        }
    }
    
    var closeOperation: Bool = true {
        didSet {
            showBtns = !closeOperation
            doneLbl.isHidden = !closeOperation
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        //
        name2LbL = UILabel()
        name2LbL.textColor = UIColor.black
        name2LbL.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBlack)
        superview.addSubview(name2LbL)
        name2LbL.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(informLbL.snp.right).offset(10)
            make.bottom.equalTo(nickNameLbl) 
        }
        //
        inform2Lbl = UILabel()
        inform2Lbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        inform2Lbl.textColor = kNotificationHintColor
        superview.addSubview(inform2Lbl)
        inform2Lbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(name2LbL.snp.right).offset(10)
            make.bottom.equalTo(name2LbL)
        }
        //
        agreenBtn = UIButton()
        agreenBtn.setTitle(LS("同意"), for: UIControlState())
        agreenBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        agreenBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview.addSubview(agreenBtn)
        agreenBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview.snp.right).offset(-45)
            make.top.equalTo(dateLbl.snp.bottom).offset(13)
            make.size.equalTo(CGSize(width: 44, height: 20))
        }
        agreenBtn.addTarget(self, action: #selector(NotificationCellAboutActivity.agreeBtnPressed), for: .touchUpInside)
        //
        denyBtn = UIButton()
        denyBtn.setTitle(LS("谢绝"), for: UIControlState())
        denyBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), for: UIControlState())
        denyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview.addSubview(denyBtn)
        denyBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(agreenBtn.snp.centerX).offset(-50)
            make.centerY.equalTo(agreenBtn)
            make.size.equalTo(agreenBtn)
        }
        denyBtn.addTarget(self, action: #selector(NotificationCellAboutActivity.denyBtnPressed), for: .touchUpInside)
        //
        doneLbl = UILabel()
        doneLbl.font = UIFont.systemFont(ofSize: 14)
        doneLbl.textColor = UIColor.black
        doneLbl.textAlignment = .right
        superview.addSubview(doneLbl)
        doneLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(denyBtn)
            make.right.equalTo(agreenBtn)
            make.height.equalTo(agreenBtn)
            make.centerY.equalTo(agreenBtn)
        }
    }
    
    
    func agreeBtnPressed() {
        if onAgreeBtnPressed == nil {
            assertionFailure()
        }
        onAgreeBtnPressed!(self)
    }
    
    func denyBtnPressed() {
        if onDenyBtnPressed == nil {
            assertionFailure()
        }
        onDenyBtnPressed!(self)
    }
}
