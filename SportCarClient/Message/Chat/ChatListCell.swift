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
    var listItem: ChatRecordListItem? {
        didSet {
            if listItem == nil {
                return
            }
            switch listItem! {
            case .ClubItem(let club):
                avatarBtn.kf_setImageWithURL(SFURL(club.logo_url!)!, forState: .Normal)
                nickNameLbl.text = club.name
                break
            case .UserItem(let user):
                avatarBtn.kf_setImageWithURL(SFURL(user.avatarUrl!)!, forState: .Normal)
                nickNameLbl.text = user.nickName
                break
            }
        }
    }
    var avatarBtn: UIButton!
    var nickNameLbl: UILabel!
    var recentTalkLbl: UILabel!
    var recentTalkTimeLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        avatarBtn = UIButton()
        avatarBtn.layer.cornerRadius = 45 / 2
        avatarBtn.clipsToBounds = true
        superview.addSubview(avatarBtn)
        avatarBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(45)
        }
        //
        nickNameLbl = UILabel()
        nickNameLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        nickNameLbl.textColor = UIColor.blackColor()
        superview.addSubview(nickNameLbl)
        nickNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarBtn.snp_right).offset(15)
            make.bottom.equalTo(avatarBtn.snp_centerY)
        }
        //
        recentTalkLbl = UILabel()
        recentTalkLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        recentTalkLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(recentTalkLbl)
        recentTalkLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nickNameLbl)
            make.top.equalTo(nickNameLbl.snp_bottom).offset(2)
            make.right.equalTo(superview).offset(-24)
        }
        //
        recentTalkTimeLbl = UILabel()
        recentTalkTimeLbl.font = UIFont.systemFontOfSize(10, weight: UIFontWeightUltraLight)
        recentTalkTimeLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(recentTalkTimeLbl)
        recentTalkTimeLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(nickNameLbl)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(0.5)
            make.bottom.equalTo(superview)
        }
    }
}
