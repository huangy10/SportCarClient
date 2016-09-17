//
//  DetailCommentCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol DetailCommentCellDelegate2: class {
    func detailCommentCellAvatarPressed(cell: DetailCommentCell2)
    
    func detailCommentCellReplyPressed(cell: DetailCommentCell2)
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
        
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAvatarBtn() {
        avatarBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(avatarBtnPressed))
            .layout({ (make) in
                make.left.equalTo(contentView).inset(15)
                make.top.equalTo(contentView)
                make.size.equalTo(35)
            })
        avatarBtn.imageView?.layer.cornerRadius = 17.5
    }
    
    func configureNameLbl() {
        nameLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightBold, textColor: UIColor.blackColor())
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp_right).offset(11)
                make.top.equalTo(contentView)
            })
    }
    
    func configureResponseLbl() {
        responseStaticLbl = contentView.addSubview(UILabel)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(nameLbl.snp_right).offset(2)
                make.bottom.equalTo(nameLbl)
            })
        responseLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightBold, textColor: UIColor.blackColor())
            .layout({ (make) in
                make.left.equalTo(responseStaticLbl.snp_right).offset(2)
                make.bottom.equalTo(nameLbl)
            })
    }
    
    func configureCommentDateLbl() {
        commentDateLbl = contentView.addSubview(UILabel)
            .config(10, fontWeight: UIFontWeightLight, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.top.equalTo(nameLbl.snp_bottom).offset(2)
            })
    }
    
    func configureContent() {
        contentLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightUltraLight, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.right.equalTo(contentView).inset(15)
                make.top.equalTo(commentDateLbl.snp_bottom).offset(7)
                make.bottom.equalTo(contentView).offset(-15)
            })
    }
    
    func configureReplyBtn() {
        replyBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(replyBtnPressed), title: LS("回复"), titleColor: UIColor(white: 0.72, alpha: 1), titleSize: 12, titleWeight: UIFontWeightUltraLight)
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
}