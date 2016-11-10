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
        superview.backgroundColor = .clear
        backgroundColor = .clear
        titleLbl = superview.addSubview(UILabel.self).config(14, textColor: kTextGray28, textAlignment: .center)
            .layout({ (make) in
//                make.center.equalTo(superview).offset(CGPoint(x: 0, y: -15) as! ConstraintOffsetTarget)
//                make.centerX.equalTo(superview)
//                make.centerY.equalTo(superview).offset(-15)
                make.edges.equalTo(superview)
                make.height.equalTo(100)
            })
    }
}
