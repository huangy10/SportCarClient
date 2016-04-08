//
//  InlineUserSelectMiniCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class InlineUserSelectMiniCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "inline_user_select_mini_cell"
    
    var user: User! {
        didSet {
            imageView.kf_setImageWithURL(user.avatarURL!)
        }
    }
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = self.contentView.addSubview(UIImageView)
            .config(nil).layout(17.5, closurer: { (make) in
                make.edges.equalTo(self.contentView)
            })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
