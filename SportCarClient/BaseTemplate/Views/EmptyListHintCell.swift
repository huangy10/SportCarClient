//
//  EmptyListHintCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class SSEmptyListHintCell: UITableViewCell {
    var titleLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.selectionStyle = .none
        let superview = self.contentView
        titleLbl = superview.addSubview(UILabel.self).config(14, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.center.equalTo(superview).offset(CGPoint(x: 0, y: -15) as! ConstraintOffsetTarget)
            })
        contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
    }
}
