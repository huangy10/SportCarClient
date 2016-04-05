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
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func createSubviews() {
        super.createSubviews()
        staticLbl.hidden = true
        arrowIcon.hidden = true
        sepLine.hidden = true
        
        let superview = self.contentView
        avatarImg = superview.addSubview(UIImageView.self)
            .config(nil)
            .layout(37, closurer: { (make) in
                make.center.equalTo(superview)
                make.size.equalTo(74)
            })
    }
    
    func setData(imageURL: NSURL, showArrow: Bool = false, zoomable: Bool = false) -> Self {
        arrowIcon.hidden = !showArrow
        avatarImg.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            if error == nil && zoomable {
                self.avatarImg.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
            }
        })
        return self
    }
}