//
//  CommentPanel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class CommentBarView: UIView {
    
    /*
    ==============================================================================================================================
    */
    var commentIcon: UIImageView?
    var contentInput: UITextView?
    var shareBtn: UIButton?
    var likeBtn: UIButton?
    
    var barheight: CGFloat
    
    override init(frame: CGRect) {
        barheight = 45
        super.init(frame: frame)
        createSubivews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        barheight = 45
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func createSubivews() {
        self.backgroundColor = UIColor(white: 0.92, alpha: 1)
        //
        let contentHeight = barheight * 0.76
        shareBtn = UIButton()
        shareBtn?.backgroundColor = UIColor.whiteColor()
        shareBtn?.layer.cornerRadius = contentHeight * 0.5
        self.addSubview(shareBtn!)
        shareBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-15)
        })
        //
        let shareBtnIcon = UIImageView(image: UIImage(named: "news_share"))
        shareBtn?.addSubview(shareBtnIcon)
        shareBtnIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 17, height: 15))
            make.center.equalTo(shareBtn!)
        }
        //
        likeBtn = UIButton()
        likeBtn?.layer.cornerRadius = contentHeight * 0.5
        likeBtn?.backgroundColor = UIColor.whiteColor()
        self.addSubview(likeBtn!)
        likeBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(shareBtn!.snp_left).offset(-9)
        })
        //
        let likeBtnIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        likeBtn?.addSubview(likeBtnIcon)
        likeBtnIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(17)
            make.center.equalTo(likeBtn!)
        }
        //
        let roundCornerContainer = UIView()
        roundCornerContainer.backgroundColor = UIColor.whiteColor()
        roundCornerContainer.layer.cornerRadius = contentHeight / 2
        self.addSubview(roundCornerContainer)
        roundCornerContainer.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(likeBtn!.snp_left).offset(-9)
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-5)
        }
        //
        commentIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        roundCornerContainer.addSubview(commentIcon!)
        commentIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(18)
            make.top.equalTo(roundCornerContainer).offset(9)
            make.size.equalTo(20)
        })
        //
        contentInput = UITextView()
        contentInput?.returnKeyType = .Done
        contentInput?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        contentInput?.textColor = UIColor(white: 0.72, alpha: 1)
        roundCornerContainer.addSubview(contentInput!)
        contentInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(commentIcon!.snp_right).offset(24)
            make.right.equalTo(roundCornerContainer).offset(-18)
            make.top.equalTo(roundCornerContainer)
            make.bottom.equalTo(roundCornerContainer)
        })
    }
    
}
