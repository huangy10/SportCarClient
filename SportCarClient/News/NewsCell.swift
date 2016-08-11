//
//  NewsCell.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/26.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class NewsCell: UITableViewCell {
    static let reusableIdentifier = "news_cell"
    /// 封面图片
    var coverImg: UIImageView?
    var coverMask: UIImageView?
    var titleLbl: UILabel?
    var commentNumLbl: UILabel?
    var shareNumLbl: UILabel?
    var likeNumLbl: UILabel?
    var likeIcon: UIImageView?
    var shareIcon: UIImageView?
    var commentIcon: UIImageView?
    
    //
    var news: News? {
        didSet {
            // 当这个news被设置时更新UI
            self.loadNewsData()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     创建所有的子view
     */
    func createSubviews() {
        let superview = self.contentView
        //
        coverImg = UIImageView()
        coverImg?.backgroundColor = UIColor.grayColor()
        superview.addSubview(coverImg!)
        coverImg?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(superview)
        })
        coverMask = UIImageView(image: UIImage(named: "news_cover_mask"))
        coverImg?.addSubview(coverMask!)
        coverMask?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(coverImg!)
            make.right.equalTo(coverImg!)
            make.bottom.equalTo(coverImg!)
            make.height.equalTo(107)
        })

        // 首先创建右下角的三个按钮
        shareNumLbl = UILabel()
        shareNumLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        shareNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        shareNumLbl?.text = "0"
        superview.addSubview(shareNumLbl!)
        shareNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview).offset(-10)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(15)
            make.width.lessThanOrEqualTo(30)
        })
        shareIcon = UIImageView(image: UIImage(named: "news_share_white"))
        superview.addSubview(shareIcon!)
        shareIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(shareNumLbl!.snp_left).offset(-3)
            make.bottom.equalTo(shareNumLbl!)
            make.size.equalTo(15)
        })
        //
        commentNumLbl = UILabel()
        commentNumLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        commentNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbl?.text = "0"
        superview.addSubview(commentNumLbl!)
        commentNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(shareIcon!.snp_left)
            make.bottom.equalTo(shareIcon!)
            make.size.equalTo(CGSize(width: 30, height: 15))
        })
        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        superview.addSubview(commentIcon!)
        commentIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(commentNumLbl!.snp_left).offset(-3)
            make.bottom.equalTo(commentNumLbl!)
            make.size.equalTo(15)
        })
        //
        likeNumLbl = UILabel()
        likeNumLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        likeNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(likeNumLbl!)
        likeNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(commentIcon!)
            make.right.equalTo(commentIcon!.snp_left)
            make.size.equalTo(CGSizeMake(30, 15))
        })
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        superview.addSubview(likeIcon!)
        likeIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(commentIcon!)
            make.right.equalTo(likeNumLbl!.snp_left).offset(-3)
            make.size.equalTo(15)
        })
        // 创建标题
        titleLbl = UILabel()
        titleLbl?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightBlack)
        titleLbl?.textColor = UIColor.whiteColor()
        titleLbl?.numberOfLines = 0
        titleLbl?.lineBreakMode = .ByWordWrapping
        super.addSubview(titleLbl!)
        titleLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(superview).offset(-10)
            make.right.equalTo(likeIcon!.snp_left)
        })
    }
    
    /**
     这个应用程序读取news中的数据并设置到的cell的ui中
     */
    func loadNewsData() {
        guard let data = self.news else{
            // 当news为空时直接返回，不做处理，不清除UI
            return
        }
        if let coverImageURL = SFURL(data.cover ?? "") {
            coverImg?.kf_setImageWithURL(coverImageURL)
        }
        titleLbl?.text = data.title
        commentNumLbl?.text = "\(data.commentNum)".strip()
        likeNumLbl?.text = "\(data.likeNum)".strip()
        shareNumLbl?.text = "\(data.shareNum)".strip()
        
        if data.liked {
            likeIcon?.image = UIImage(named: "news_like_liked")
        }else {
            likeIcon?.image = UIImage(named: "news_like_unliked")
        }
    }
}
