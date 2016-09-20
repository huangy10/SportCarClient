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
        replyBtn?.isHidden = user.isHost
        // 设置头像
        avatarBtn?.kf_setImageWithURL(user.avatarURL!, forState: UIControlState())
        //
        nameLbl?.text = user.nickName
        // 检查是否有回应对象
        if let targetComment = comment?.responseTo {
            responseLbl?.isHidden = false
            responseStaticLbl?.isHidden = false
            responseLbl?.text = targetComment.user?.nickName
        }else{
            responseLbl?.isHidden = true
            responseStaticLbl?.isHidden = true
        }
        //
        commentDateLbl?.text = dateDisplay(data.createdAt!)
        // 设置评论内容
        if let content = data.content {
            commentContentLbl?.isHidden = false
            commentContentLbl?.text = content
        }else{
            commentContentLbl?.isHidden = true
        }
        commentImage?.isHidden = true
    }
}
