//
//  PropertyCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher

/// single property viewer cell
class SSPropertyCell: SSPropertyBaseCell {
    
    class override var reuseIdentifier: String {
        return "common_cell"
    }
    
    // Try to avoid accessing the subviews directly
    internal var infoLbl: UILabel!
    internal var icon: UIImageView!
    
    var editable: Bool = false {
        didSet {
            arrowIcon.hidden = !editable
        }
    }
    
    internal override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        infoLbl = superview.addSubview(UILabel.self)
            .config(14, textColor: UIColor.blackColor())
            .layout({ (make) in
                make.centerY.equalTo(staticLbl)
                make.right.equalTo(arrowIcon.snp_left).offset(-15)
            })
        icon = superview.addSubview(UIImageView.self)
            .config(nil)
            .layout(10, closurer: { (make) in
                make.centerY.equalTo(staticLbl)
                make.right.equalTo(infoLbl.snp_left).offset(-8)
                make.size.equalTo(20)
            })
    }
    
    /**
     设置数据
     
     - parameter propertyName:     属性名称
     - parameter propertyValue:    属性取值
     - parameter propertyImageURL: 关联图片的url
     - parameter editable:         是否可以编辑
     
     - returns: 返回获取Image的task
     */
    func setData(
        propertyName: String,
        propertyValue: String?,
        propertyImageURL: NSURL? = nil,
        propertyEmptyPlaceHolder: String? = nil,
        editable: Bool = true) -> Self {
            staticLbl.text = propertyName
            infoLbl.text = propertyValue ?? propertyEmptyPlaceHolder
            if propertyImageURL != nil {
                icon.kf_setImageWithURL(propertyImageURL!)
            } else {
                icon.image = nil
            }
            self.editable = editable
            return self
    }
}
