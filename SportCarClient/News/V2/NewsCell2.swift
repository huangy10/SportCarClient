//
//  NewsCell2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class NewsCell2: UITableViewCell {
    var cover: UIImageView!
    var titleLbl: UILabel!
    var commentNumLbl: UILabel!
    var commentIcon: UIImageView!
    var shareNumLbl: UILabel!
    var shareIcon: UIImageView!
    var likeNumLbl: UILabel!
    var likeIcon: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCover()
        configureShareNumDisplay()
        configureCommentNumDisplay()
        configureLikeNumDisplay()
        configureTitleLbl()
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCover() {
        cover = contentView.addSubview(UIImageView.self)
            .layout({ (make) in
                make.edges.equalTo(contentView)
            })
        cover.addSubview(UIImageView.self).config(UIImage(named: "news_cover_mask"))
            .layout { (make) in
                make.right.equalTo(cover)
                make.left.equalTo(cover)
                make.bottom.equalTo(cover)
                make.height.equalTo(cover.snp.width).multipliedBy(0.285)
        }
    }
    
    func configureTitleLbl() {
        titleLbl = contentView.addSubview(UILabel.self)
            .config(17, fontWeight: UIFontWeightBlack, textColor: UIColor.white)
            .layout({ (make) in
                make.left.equalTo(contentView) .offset(15)
                make.bottom.equalTo(contentView).offset(-10)
                make.right.equalTo(likeIcon.snp.left).offset(-5)
            })
        titleLbl.numberOfLines = 0
    }
    
    func configureShareNumDisplay() {
        shareNumLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1), text: "0")
            .layout({ (make) in
                make.bottom.equalTo(contentView).offset(-10)
                make.right.equalTo(contentView).offset(-15)
                make.width.equalTo(30)
            })
        shareIcon = contentView.addSubview(UIImageView.self)
            .config(UIImage(named: "news_share_white"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.right.equalTo(shareNumLbl.snp.left).offset(-3)
                make.bottom.equalTo(shareNumLbl)
                make.size.equalTo(15)
            })
    }
    
    func configureCommentNumDisplay() {
        commentNumLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1), text: "0")
            .layout({ (make) in
                make.right.equalTo(shareIcon.snp.left)
                make.bottom.equalTo(shareIcon)
                make.width.equalTo(30)
            })
        commentIcon = contentView.addSubview(UIImageView.self)
            .config(UIImage(named: "news_comment"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.right.equalTo(commentNumLbl.snp.left).offset(-3)
                make.bottom.equalTo(commentNumLbl)
                make.size.equalTo(15)
            })
    }
    
    func configureLikeNumDisplay() {
        likeNumLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1), text: "0")
            .layout({ (make) in
                make.bottom.equalTo(commentNumLbl)
                make.right.equalTo(commentIcon.snp.left)
                make.width.equalTo(30)
            })
        likeIcon = contentView.addSubview(UIImageView.self)
            .config(UIImage(named: "news_like_unliked"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.bottom.equalTo(likeNumLbl)
                make.right.equalTo(likeNumLbl.snp.left).offset(-3)
                make.size.equalTo(15)
            })
    }
    
    func setData(_ coverImage: URL, title: String, likeNum: Int, commentNum: Int, shareNum: Int, liked: Bool) {
        cover.kf.setImage(with: coverImage)
        titleLbl.text = title
        if likeNum > 99 {
            likeNumLbl.text = "99+"
        } else {
            likeNumLbl.text = "\(likeNum)"
        }
        
        if commentNum > 99 {
            commentNumLbl.text = "99+"
        } else {
            commentNumLbl.text = "\(commentNum)"
        }
        
        if shareNum > 99 {
            shareNumLbl.text = "99+"
        } else {
            shareNumLbl.text = "\(shareNum)"
        }
        
        if liked {
            likeIcon.image = UIImage(named: "news_like_liked")
        } else {
            likeIcon.image = UIImage(named: "news_like_unliked")
        }
    }
}
