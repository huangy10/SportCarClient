//
//  ActivityCommentPanel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityCommentPanel: CommentBarView {
    
    override func createSubivews() {
        super.createSubivews()
        let contentHeight = barheight * 0.76
        shareBtn?.hidden = true
        likeBtn?.snp_remakeConstraints(closure: { (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-15)
        })
    }
    
}
