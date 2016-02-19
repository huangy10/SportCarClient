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
        let hostUser = User.objects.hostUser!
        if hostUser.userID == user.userID {
            replyBtn?.hidden = true
        }else{
            replyBtn?.hidden = false
        }
        //
        avatarBtn?.kf_setImageWithURL(SFURL(user.avatarUrl!)!, forState: .Normal)
        //
        nameLbl?.text = user.nickName
        //
        if let targetComment = comment.responseTo {
            responseLbl?.hidden = false
            responseStaticLbl?.hidden = false
            responseLbl?.text = targetComment.user?.nickName
        }else{
            responseLbl?.hidden = true
            responseStaticLbl?.hidden = true
        }
        //
        commentDateLbl?.text = dateDisplay(comment.createdAt!)
        // 设置评论内容
        if let content = comment.content {
            commentContentLbl?.hidden = false
            commentContentLbl?.text = content
        }else {
            commentContentLbl?.hidden = true
        }
        // 设置评论图片
        if let image = comment.image {
            commentImage?.hidden = false
            commentImage?.kf_setImageWithURL(SFURL(image)!, forState: .Normal)
            let headerView: UIView
            if commentContentLbl!.hidden {
                headerView = avatarBtn!
            }else{
                headerView = commentContentLbl!
            }
            commentImage?.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(headerView.snp_bottom).offset(7)
                make.right.equalTo(nameLbl!)
                make.height.equalTo(82)         // 图片的高度限定
                make.right.equalTo(replyBtn!.snp_left)
            })
        }else{
            commentImage?.hidden = true
        }
    }
}
