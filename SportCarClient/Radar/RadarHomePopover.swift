//
//  RadarHomePopover.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class RadarHomePopoverController: UIViewController {
    var newStatusBtn: UIButton!
    var newChatBtn: UIButton!
    var newActivityBtn: UIButton!

    
    func createSubviews() {
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        //
        newStatusBtn = UIButton()
        superview.addSubview(newStatusBtn)
        newStatusBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(superview).dividedBy(3)
        }
        //
        let statusIcon = UIImageView(image: UIImage(named: "radar_new_status"))
        newStatusBtn.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(17.5)
            make.size.equalTo(17)
            make.centerY.equalTo(newStatusBtn)
        }
        let statusLbl = UILabel()
        statusLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        statusLbl.textColor = UIColor.black
        statusLbl.text = LS("发布动态")
        newStatusBtn.addSubview(statusLbl)
        statusLbl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(newStatusBtn)
            make.left.equalTo(statusIcon.snp.right).offset(18)
        }
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        newStatusBtn.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(newStatusBtn)
            make.left.equalTo(newStatusBtn)
            make.bottom.equalTo(newStatusBtn)
            make.height.equalTo(0.5)
        }
        //
        newChatBtn = UIButton()
        superview.addSubview(newChatBtn)
        newChatBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(newStatusBtn.snp.bottom)
            make.height.equalTo(superview).dividedBy(3)
        }
        //
        let chatIcon = UIImageView(image: UIImage(named: "radar_new_chat"))
        newChatBtn.addSubview(chatIcon)
        chatIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(17.5)
            make.size.equalTo(17)
            make.centerY.equalTo(newChatBtn)
        }
        //
        let chatLbl = UILabel()
        chatLbl.textColor = UIColor.black
        chatLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        chatLbl.text = LS("新建聊天")
        newChatBtn.addSubview(chatLbl)
        chatLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(chatIcon.snp.right).offset(18)
            make.centerY.equalTo(newChatBtn)
        }
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        newChatBtn.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(newChatBtn)
            make.height.equalTo(0.5)
        }
        //
        newActivityBtn = UIButton()
        superview.addSubview(newActivityBtn)
        newActivityBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(newChatBtn.snp.bottom)
            make.bottom.equalTo(superview)
        }
        //
        let actIcon = UIImageView(image: UIImage(named: "radar_new_activity"))
        newActivityBtn.addSubview(actIcon)
        actIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(17.5)
            make.centerY.equalTo(superview)
            make.size.equalTo(17)
        }
        //
        let actLbl = UILabel()
        actLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        actLbl.textColor = UIColor(white: 0.945, alpha: 1)
        actLbl.text = LS("发起活动")
        newActivityBtn.addSubview(actLbl)
        actLbl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(newActivityBtn)
            make.left.equalTo(actIcon.snp.right).offset(18)
        }
    }
}
