//
//  CommonHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class SSCommonHeader: UITableViewHeaderFooterView {
    
    class var reuseIdentifier: String {
        return "common_header"
    }
    
    class func registerTableView(_ tableView: UITableView) {
        tableView.register(self.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    var titleLbl: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.contentView.backgroundColor = UIColor.RGB(239, 239, 244)
        titleLbl = self.contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightSemibold)
            .layout({ (make) in
                make.left.equalTo(self.contentView).offset(15)
                make.centerY.equalTo(self.contentView)
            })
    }
}


extension UITableView {
    func ss_reusableHeader<T: SSCommonHeader>(_ type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}
