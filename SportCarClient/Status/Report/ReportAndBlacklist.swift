//
//  ReportAndBlacklist.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

let kReportTitles = [LS("色情低俗"), LS("广告骚扰"), LS("政治敏感"), LS("谣言"), LS("违法(暴力恐怖、违禁品等)"), LS("侵权举报(诽谤、抄袭、冒用...)")]


class ReportBlacklistViewController: PresentTemplateViewController {
    
    var userID: Int32 = 0
    var reportType: String // status or user or club
    
    fileprivate var container1: UIView!
    fileprivate var container2: UIView!
    
    init (userID: Int32, reportType: String = "user", parent: UIViewController) {
        self.userID = userID
        self.reportType = reportType
        super.init(parent: parent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createContent() {
        let superview = self.view!
        // 创建第一版面
        container1 = UIView()
        container.addSubview(container1)
        container1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(sepLine.snp.bottom)
            make.bottom.equalTo(superview)
        }
        // 创建第二版面
        container2 = UIView()
        container.addSubview(container2)
        container2.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(container1)
        }
        //
        var headerView = sepLine!
        var index = 0
        for title in kReportTitles {
            let btn = UIButton()
            btn.setTitle(title, for: UIControlState())
            btn.setTitleColor(UIColor.white, for: UIControlState())
            btn.tag = index
            btn.addTarget(self, action: #selector(ReportBlacklistViewController.reportItemPressed(_:)), for: .touchUpInside)
            container2.addSubview(btn)
            btn.snp.makeConstraints({ (make) -> Void in
                make.centerX.equalTo(container2)
                make.top.equalTo(headerView.snp.bottom).offset(45)
                make.height.equalTo(24)
                make.width.equalTo(container2)
            })
            headerView = btn
            index += 1
        }
    }
    
    func reportBtnPressed() {
        self.container2.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.container1.layer.opacity = 0
            self.container2.layer.opacity = 1
            }, completion: { (_) -> Void in
                self.container1.isHidden = true
        }) 
    }
    
    func reportItemPressed(_ sender: UIButton) {
        // TODO: 将举报内容发送给服务器
//        showToast(LS("举报内容发送成功"), onSelf: false)
        hideAnimated()
        let delay: DispatchTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) { 
            UIApplication.shared.keyWindow?.rootViewController?.showToast(LS("举报内容发送成功"), onSelf: true)
        }
        
    }
}
