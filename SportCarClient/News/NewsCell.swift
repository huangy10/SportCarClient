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
        coverImg?.backgroundColor = UIColor.gray
        superview.addSubview(coverImg!)
        coverImg?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(superview)
        })
        coverMask = UIImageView(image: UIImage(named: "news_cover_mask"))
        coverImg?.addSubview(coverMask!)
        coverMask?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(coverImg!)
            make.right.equalTo(coverImg!)
            make.bottom.equalTo(coverImg!)
            make.height.equalTo(107)
        })

        // 首先创建右下角的三个按钮
        shareNumLbl = UILabel()
        shareNumLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        shareNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        shareNumLbl?.text = "0"
        superview.addSubview(shareNumLbl!)
        shareNumLbl?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(superview).offset(-10)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(15)
            make.width.lessThanOrEqualTo(30)
        })
        shareIcon = UIImageView(image: UIImage(named: "news_share_white"))
        shareIcon?.contentMode = .scaleAspectFit
        superview.addSubview(shareIcon!)
        shareIcon?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(shareNumLbl!.snp.left).offset(-3)
            make.bottom.equalTo(shareNumLbl!)
            make.size.equalTo(15)
        })
        //
        commentNumLbl = UILabel()
        commentNumLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        commentNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbl?.text = "0"
        superview.addSubview(commentNumLbl!)
        commentNumLbl?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(shareIcon!.snp.left)
            make.bottom.equalTo(shareIcon!)
            make.size.equalTo(CGSize(width: 30, height: 15))
        })
        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        commentIcon?.contentMode = .scaleAspectFit
        superview.addSubview(commentIcon!)
        commentIcon?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(commentNumLbl!.snp.left).offset(-3)
            make.bottom.equalTo(commentNumLbl!)
            make.size.equalTo(15)
        })
        //
        likeNumLbl = UILabel()
        likeNumLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        likeNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(likeNumLbl!)
        likeNumLbl?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(commentIcon!)
            make.right.equalTo(commentIcon!.snp.left)
            make.size.equalTo(CGSize(width: 30, height: 15))
        })
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        likeIcon?.contentMode = .scaleAspectFit
        superview.addSubview(likeIcon!)
        likeIcon?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(commentIcon!)
            make.right.equalTo(likeNumLbl!.snp.left).offset(-3)
            make.size.equalTo(15)
        })
        // 创建标题
        titleLbl = UILabel()
        titleLbl?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBlack)
        titleLbl?.textColor = UIColor.white
        titleLbl?.numberOfLines = 0
        titleLbl?.lineBreakMode = .byWordWrapping
        super.addSubview(titleLbl!)
        titleLbl?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(superview).offset(-10)
            make.right.equalTo(likeIcon!.snp.left)
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
            coverImg?.kf.setImage(with: coverImageURL)
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
