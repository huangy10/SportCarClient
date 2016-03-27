//
//  NewsDetailCommentCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
import UIKit
import Kingfisher

class NewsDetailCommentCell: DetailCommentCell {
    /// 本Cell展示的comment
    var comment: NewsComment? {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    
    override func loadDataAndUpdateUI() {
        guard let data = comment else{
            return
        }
        let user = data.user!
        replyBtn?.hidden = user.isHost
        // 设置头像
        avatarBtn?.kf_setImageWithURL(user.avatarURL!, forState: .Normal)
        //
        nameLbl?.text = user.nickName
        // 检查是否有回应对象
        if let targetComment = comment?.responseTo {
            responseLbl?.hidden = false
            responseStaticLbl?.hidden = false
            responseLbl?.text = targetComment.user?.nickName
        }else{
            responseLbl?.hidden = true
            responseStaticLbl?.hidden = true
        }
        //
        commentDateLbl?.text = dateDisplay(data.createdAt!)
        // 设置评论内容
        if let content = data.content {
            commentContentLbl?.hidden = false
            commentContentLbl?.text = content
        }else{
            commentContentLbl?.hidden = true
        }
        commentImage?.hidden = true
    }
}