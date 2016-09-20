//
//  PersonStatusHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class PersonStatusHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "person_status_header"
    
    var titleLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.backgroundColor = UIColor.white
        titleLbl = UILabel()
        titleLbl.textColor = UIColor.black
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        self.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
        }
    }
}
