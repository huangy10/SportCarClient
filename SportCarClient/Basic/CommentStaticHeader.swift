//
//  CommentStaticHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/31.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class CommentStaticHeader: UITableViewHeaderFooterView {
    var sepLine: UIView!
    var lbl: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        configureSepLine()
        configureLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureSepLine() {
        sepLine = contentView.addSubview(UIView.self).config(kTextGray28)
            .layout({ (make) in
                make.right.equalToSuperview().offset(-15).priority(250)
                make.left.equalToSuperview().offset(15).priority(250)
                make.centerY.equalToSuperview()
                make.height.equalTo(0.5)
            })
    }
    
    func configureLabel() {
        lbl = contentView.addSubview(UILabel.self).config(.white)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28, textAlignment: .center, text: LS("评论"))
            .layout({ (make) in
                make.center.equalTo(self)
                make.height.equalTo(self)
                make.width.equalTo(70)
            })
    }
}
