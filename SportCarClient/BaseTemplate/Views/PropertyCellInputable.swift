//
//  PropertyCellInputable.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class SSPropertyInputableCell: SSPropertyBaseCell {
    var contentInput: UITextField!
    internal var wrapper: UIScrollView!
    
    var inputable: Bool = true {
        didSet {
            wrapper.userInteractionEnabled = inputable
        }
    }
    
    override class var reuseIdentifier: String {
        return "inputable_cell"
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        // You should put the textfield into an UIScrollView to avoid the auto offset adjustment, which could not be closed. Stupid apple!
        wrapper = superview.addSubview(UIScrollView).config(UIColor.whiteColor()).layout({ (make) in
            make.centerY.equalTo(staticLbl)
            make.right.equalTo(arrowIcon.snp_left).offset(-8)
            make.height.equalTo(superview)
            make.left.equalTo(staticLbl.snp_right).offset(30)
        })

        wrapper.scrollEnabled = false
        contentInput = wrapper.addSubview(UITextField)
            .config(textAlignment: .Right)
            .layout({ (make) in
                make.centerY.equalTo(staticLbl)
                make.right.equalTo(arrowIcon.snp_left).offset(-8)
                make.height.equalTo(superview)
                make.left.equalTo(staticLbl.snp_right).offset(30)
            })
    }
    
    func extraSettings(
        delegate: UITextFieldDelegate?,
        text: String? = nil,
        placeholder: String? = nil
        ) {
        if delegate != nil {
            // only override, never clear
            contentInput.delegate = delegate
        }
        contentInput.text = text
        contentInput.placeholder = placeholder
    }
    
    func hideArrowIcon() {
        if arrowIcon.hidden {
            return
        }
        arrowIcon.hidden = true
        wrapper.snp_remakeConstraints(closure: { (make) in
            make.centerY.equalTo(staticLbl)
            make.right.equalTo(arrowIcon)
            make.height.equalTo(self.contentView)
            make.left.equalTo(staticLbl.snp_right).offset(30)
        })
        contentInput.snp_remakeConstraints { (make) in
            make.centerY.equalTo(staticLbl)
            make.right.equalTo(arrowIcon)
            make.height.equalTo(self.contentView)
            make.left.equalTo(staticLbl.snp_right).offset(30)
        }
        self.contentView.layoutIfNeeded()
    }
}