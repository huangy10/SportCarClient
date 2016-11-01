//
//  DetailCommentCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol DetailCommentCellDelegate2: class {
    func detailCommentCellAvatarPressed(_ cell: DetailCommentCell2)
    
    func detailCommentCellReplyPressed(_ cell: DetailCommentCell2)
}


class DetailCommentCell2: UITableViewCell {
    
    weak var delegate: DetailCommentCellDelegate2?
    
    var avatarBtn: UIButton!
    var nameLbl: UILabel!
    var responseStaticLbl: UILabel!
    var responseLbl: UILabel!
    var commentDateLbl: UILabel!
    var replyBtn: UIButton!
    var contentLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAvatarBtn()
        configureNameLbl()
        configureResponseLbl()
        configureCommentDateLbl()
        configureContent()
        configureReplyBtn()
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAvatarBtn() {
        avatarBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(avatarBtnPressed))
            .layout({ (make) in
                make.left.equalTo(contentView).inset(15)
                make.top.equalTo(contentView)
                make.size.equalTo(35)
            })
        avatarBtn.imageView?.layer.cornerRadius = 17.5
    }
    
    func configureNameLbl() {
        nameLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightSemibold, textColor: UIColor.black)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(11)
                make.top.equalTo(contentView)
            })
    }
    
    func configureResponseLbl() {
        responseStaticLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28)
            .layout({ (make) in
                make.left.equalTo(nameLbl.snp.right).offset(2)
                make.bottom.equalTo(nameLbl)
            })
        responseLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightSemibold, textColor: UIColor.black)
            .layout({ (make) in
                make.left.equalTo(responseStaticLbl.snp.right).offset(2)
                make.bottom.equalTo(nameLbl)
            })
    }
    
    func configureCommentDateLbl() {
        commentDateLbl = contentView.addSubview(UILabel.self)
            .config(10, fontWeight: UIFontWeightRegular, textColor: kTextGray28)
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.top.equalTo(nameLbl.snp.bottom).offset(2)
            })
    }
    
    func configureContent() {
        contentLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.right.equalTo(contentView).inset(15)
                make.top.equalTo(commentDateLbl.snp.bottom).offset(7)
                make.bottom.equalTo(contentView).offset(-15)
            })
    }
    
    func configureReplyBtn() {
        replyBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(replyBtnPressed), title: LS("回复"), titleColor: kTextGray28, titleSize: 12, titleWeight: UIFontWeightRegular)
            .layout({ (make) in
                make.right.equalTo(contentView).inset(15)
                make.top.equalTo(commentDateLbl)
                make.height.equalTo(17)
                make.width.equalTo(25)
            })
    }
    
    func avatarBtnPressed() {
        delegate?.detailCommentCellAvatarPressed(self)
    }
    
    func replyBtnPressed() {
        delegate?.detailCommentCellReplyPressed(self)
    }
    
    func setData(_ avatarURL: URL, name: String, content: String, commentAt: Date, responseTo: String?, showReplyBtn: Bool) {
        avatarBtn.kf.setImage(with: avatarURL, for: .normal)
        nameLbl.text = name
        contentLbl.text = content
        commentDateLbl.text = dateDisplay(commentAt)
        if let temp = responseTo {
            responseLbl.isHidden = false
            responseStaticLbl.isHidden = false
            responseLbl.text = temp
        } else {
            responseLbl.isHidden = true
            responseStaticLbl.isHidden = true
        }
        replyBtn.isHidden = !showReplyBtn
    }
}
