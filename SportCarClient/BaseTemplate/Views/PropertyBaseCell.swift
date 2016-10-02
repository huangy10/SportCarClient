//
//  PropertyBaseCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class SSPropertyBaseCell: UITableViewCell {
    internal var staticLbl: UILabel!
    internal var arrowIcon: UIImageView!
    internal var sepLine: UIView!
    
    class var reuseIdentifier: String {
        return "base_cell"
    }
    
    class func registerTableView(_ tableView: UITableView) {
        tableView.register(self.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = self.contentView
        staticLbl = superview.addSubview(UILabel.self)
            .config(14, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.centerY.equalTo(superview)
                make.left.equalTo(superview).offset(15)
            })
        arrowIcon = superview.addSubview(UIImageView.self)
            .config(UIImage(named: "account_btn_next_icon"))
            .layout({ (make) in
                make.centerY.equalTo(staticLbl)
                make.right.equalTo(superview).offset(-15)
                make.size.equalTo(CGSize(width: 9, height: 15))
            })
        sepLine = superview.addSubview(UIView.self)
            .config(UIColor(white: 0.933, alpha: 1))
            .layout { (make) in
                make.top.equalTo(staticLbl.snp.bottom).offset(11)
                make.right.equalTo(superview).offset(-15)
                make.height.equalTo(0.5)
                make.left.equalTo(superview).offset(15)
        }
    }
    
    
}


extension UITableViewCell {
    func ss_toPropertyCell<T: SSPropertyBaseCell>(_ type: T.Type) -> T {
        return self as! T
    }
}


extension UITableView {
    func ss_reuseablePropertyCell<T: SSPropertyBaseCell>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath).ss_toPropertyCell(type)
    }
}
