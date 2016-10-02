//
//  AvatarCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher


class SSAvatarCell: SSPropertyBaseCell {
    
    class override var reuseIdentifier: String {
        return "avatar_cell"
    }
    
    internal var avatarImg: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func createSubviews() {
        super.createSubviews()
        staticLbl.isHidden = true
        arrowIcon.isHidden = true
        sepLine.isHidden = true
        
        let superview = self.contentView
        avatarImg = superview.addSubview(UIImageView.self)
            .config(nil)
            .layout(37, closurer: { (make) in
                make.center.equalTo(superview)
                make.size.equalTo(74)
            })
    }
    
    func setData(_ imageURL: URL, showArrow: Bool = false, zoomable: Bool = false) -> Self {
        arrowIcon.isHidden = !showArrow
        
        avatarImg.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil) { (image, error, _, _) in
            if zoomable && error == nil {
                self.avatarImg.setupForImageViewer(nil, backgroundColor: UIColor.black)
            }
        }
        return self
    }
}
