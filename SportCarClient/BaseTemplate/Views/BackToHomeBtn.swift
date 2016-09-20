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
        NotificationCenter.default.removeObserver(self)
    }
    
    func createSubview() {
        setImage(UIImage(named: "home_back"), for: UIControlState())
        bounds = CGRect(x: 0, y: 0, width: 15, height: 13.5)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(unreadStatusChanged), name: NSNotification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
    }
    
    func wrapToBarBtn() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self)
    }
    
    func unreadStatusChanged() {
        let unreadNum = MessageManager.defaultManager.unreadNum
        DispatchQueue.main.async { 
            self.messageMark.isHidden = unreadNum == 0
        }
    }
}
