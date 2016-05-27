//
//  LocationSelectCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class LocationSelectCell: UITableViewCell {
    
    var titleLbl: UILabel!
    var detailLbl:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        titleLbl = superview.addSubview(UILabel)
            .config(14)
            .layout({ (make) in
                make.left.equalTo(superview).offset(15)
                make.right.equalTo(superview).offset(-15)
                make.bottom.equalTo(superview.snp_centerY)
            })
        detailLbl = superview.addSubview(UILabel)
            .config(12, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(titleLbl)
                make.right.equalTo(titleLbl)
                make.top.equalTo(titleLbl.snp_bottom)
            })
    }
    
}
