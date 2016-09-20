//
//  ActivityCommentCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityCommentCell: DetailCommentCell {
    var comment: ActivityComment!
    
    override func loadDataAndUpdateUI() {
        let user = comment.user!
        //
        replyBtn?.isHidden = user.isHost
        //
        avatarBtn?.kf_setImageWithURL(user.avatarURL!, forState: UIControlState())
        //
        nameLbl?.text = user.nickName
        //
        if let targetComment = comment.responseTo {
            responseLbl?.isHidden = false
            responseStaticLbl?.isHidden = false
            responseLbl?.text = targetComment.user?.nickName
        }else{
            responseLbl?.isHidden = true
            responseStaticLbl?.isHidden = true
        }
        //
        commentDateLbl?.text = dateDisplay(comment.createdAt!)
        // 设置评论内容
        if let content = comment.content {
            commentContentLbl?.isHidden = false
            commentContentLbl?.text = content
        }else {
            commentContentLbl?.isHidden = true
        }
        // 设置评论图片
        commentImage?.isHidden = true
    }
}
