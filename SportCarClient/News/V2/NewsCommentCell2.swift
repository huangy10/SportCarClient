//
//  NewsCommentCell2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class NewsCommentCell2: DetailCommentCell2 {
    
    func setData(avatarURL: NSURL, name: String, content: String, commentAt: NSDate, responseTo: String?, showReplyBtn: Bool) {
        avatarBtn.kf_setImageWithURL(avatarURL, forState: .Normal)
        nameLbl.text = name
        contentLbl.text = content
        commentDateLbl.text = dateDisplay(commentAt)
        if let temp = responseTo {
            responseLbl.hidden = false
            responseStaticLbl.hidden = false
            responseLbl.text = temp
        } else {
            responseLbl.hidden = true
            responseStaticLbl.hidden = true
        }
        replyBtn.hidden = !showReplyBtn
    }
    
}