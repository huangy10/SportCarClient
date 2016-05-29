//
//  BackToHomeBtn.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class BackToHomeBtn: UIButton {
    var messageMark: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func createSubview() {
        setImage(UIImage(named: "home_back"), forState: .Normal)
        bounds = CGRectMake(0, 0, 15, 13.5)
//        imageView?.contentMode = .ScaleAspectFit
        clipsToBounds = false
        
        messageMark = self.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout({ (make) in
                make.centerX.equalTo(self.snp_right)
                make.centerY.equalTo(self.snp_top)
                make.size.equalTo(8)
            }).toRound(4)
        // check the unread status
        unreadStatusChanged()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(unreadStatusChanged), name: kUnreadNumberDidChangeNotification, object: nil)
    }
    
    func wrapToBarBtn() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self)
    }
    
    func unreadStatusChanged() {
        let unreadNum = MessageManager.defaultManager.unreadNum
        dispatch_async(dispatch_get_main_queue()) { 
            self.messageMark.hidden = unreadNum == 0
        }
    }
}
