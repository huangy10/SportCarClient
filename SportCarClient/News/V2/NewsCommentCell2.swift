//
//  NewsCommentCell2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class NewsCommentCell2: DetailCommentCell2 {
    
    func setData(_ avatarURL: URL, name: String, content: String, commentAt: Date, responseTo: String?, showReplyBtn: Bool) {
        avatarBtn.kf_setImageWithURL(avatarURL, forState: UIControlState())
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
