//
//  ChatListCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class ChatListCell: UITableViewCell {
    
    static let reuseIdentifier = "chat_list_cell"
    
    var data: RosterItem! {
        didSet {
            recentTalkLbl.text = data.recentChatDes
            recentTalkTimeLbl.text = dateDisplay(data.updatedAt!)
            setUnreadNumber(Int(data.unreadNum))
//            if data.alwaysOnTop {
//                contentView.backgroundColor = UIColor(white: 0, alpha: 0.04)
//            } else {
//                contentView.backgroundColor = UIColor.white
//            }
            switch data.data! {
            case .user(let user):
                avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
                nickNameLbl.text = user.chatName
            case .club(let club):
                avatarBtn.kf.setImage(with: club.logoURL!, for: .normal)
                nickNameLbl.text = club.name! + "(\(club.memberNum))"
            }
        }
    }
    var avatarBtn: UIButton!
    var unreadLbl: UILabel!
    var nickNameLbl: UILabel!
    var recentTalkLbl: UILabel!
    var recentTalkTimeLbl: UILabel!
    
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
        avatarBtn.layer.cornerRadius = 45 / 2
        avatarBtn.clipsToBounds = true
        superview.addSubview(avatarBtn)
        avatarBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(45)
        }
        //
        unreadLbl = UILabel()
        unreadLbl.font = UIFont.systemFont(ofSize: 9, weight: UIFontWeightRegular)
        unreadLbl.textColor = UIColor.white
        unreadLbl.backgroundColor = kHighlightedRedTextColor
        unreadLbl.layer.cornerRadius = 9
        unreadLbl.clipsToBounds = true
        unreadLbl.textAlignment = .center
        unreadLbl.isHidden = true
        superview.addSubview(unreadLbl)
        unreadLbl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(avatarBtn)
            make.centerX.equalTo(avatarBtn.snp.right)
            make.size.equalTo(18)
        }
        //
        nickNameLbl = UILabel()
        nickNameLbl.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        nickNameLbl.textColor = UIColor.black
        superview.addSubview(nickNameLbl)
        nickNameLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp.right).offset(15)
            make.bottom.equalTo(avatarBtn.snp.centerY)
        }
        //
        recentTalkLbl = UILabel()
        recentTalkLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        recentTalkLbl.textColor = UIColor(white: 0, alpha: 0.58)
        superview.addSubview(recentTalkLbl)
        recentTalkLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl)
            make.top.equalTo(nickNameLbl.snp.bottom).offset(2)
            make.right.equalTo(superview).offset(-24)
        }
        //
        recentTalkTimeLbl = UILabel()
        recentTalkTimeLbl.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        recentTalkTimeLbl.textColor = kTextGray28
        superview.addSubview(recentTalkTimeLbl)
        recentTalkTimeLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(nickNameLbl)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(0.5)
            make.bottom.equalTo(superview)
        }
    }
    
    func setUnreadNumber(_ num: Int) {
        if num > 0 {
            unreadLbl.text = "\(num)"
            unreadLbl.isHidden = false
        }else {
            unreadLbl.isHidden = true
        }
    }
}
