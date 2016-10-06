//
//  PropertyButtons.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit



class SimpleLabelCell: UITableViewCell {
    
    var titleLbl: UILabel!
    
    func configureTitleLbl() {
        titleLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightUltraLight, textColor: kHighlightRed, textAlignment: .center)
            .layout({ (make) in
                make.center.equalTo(contentView)
            })
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureTitleLbl()
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
