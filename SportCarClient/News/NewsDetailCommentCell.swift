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
        let hostUser = User.objects.hostUser()
        if user.isEqualToSimple(hostUser!) {
            replyBtn?.hidden = true
        }else{
            replyBtn?.hidden = false
        }
        // 设置头像
        avatarBtn?.kf_setImageWithURL(SFURL(user.avatarUrl!)!, forState: .Normal)
        //
        nameLbl?.text = user.nickName
        // 检查是否有回应对象
        if let targetComment = comment?.commentTo {
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
        // 设置评论图片
        if let image = data.image {
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