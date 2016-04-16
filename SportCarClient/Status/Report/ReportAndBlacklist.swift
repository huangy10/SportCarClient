//
//  ReportAndBlacklist.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

let kReportTitles = [LS("色情低俗"), LS("广告骚扰"), LS("政治敏感"), LS("谣言"), LS("违法(暴力恐怖、违禁品等)"), LS("侵权举报(诽谤、抄袭、毛用...)")]


class ReportBlacklistViewController: PresentTemplateViewController {
    
    var user: User?
    
    private var displayStage: Int = 0
    
    private var container1: UIView!
    private var container2: UIView!
    // 第一版面
    private var reportBtn: UIButton!
    private var blacklistLbl: UILabel!
    private var blacklistBtn: UISwitch!
    var blacklist: Bool = false
    var dirty: Bool = false
    // 第二版面
    
    init (user: User?, parent: UIViewController) {
        super.init(parent: parent)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createContent() {
        let superview = self.view
        // 创建第一版面
        container1 = UIView()
        container.addSubview(container1)
        container1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(sepLine.snp_bottom)
            make.bottom.equalTo(superview)
        }
        //
        reportBtn = UIButton()
        reportBtn.setTitle(LS("举报"), forState: .Normal)
        reportBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        reportBtn.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        container1.addSubview(reportBtn)
        reportBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container1)
            make.top.equalTo(container1).offset(45)
            make.size.equalTo(CGSizeMake(40, 25))
        }
        reportBtn.addTarget(self, action: #selector(ReportBlacklistViewController.reportBtnPressed), forControlEvents: .TouchUpInside)
        if user != nil {
            blacklistLbl = container1.addSubview(UILabel.self)
                .config(17, textColor: UIColor.whiteColor(), textAlignment: .Center, text: LS("屏蔽"))
                .layout({ (make) in
                    make.centerX.equalTo(container1)
                    make.top.equalTo(reportBtn.snp_bottom).offset(45)
                })
            blacklistBtn = container1.addSubview(UISwitch.self)
                .config(self, selector: #selector(blacklistPressed))
                .layout({ (make) in
                    make.centerX.equalTo(container1)
                    make.top.equalTo(blacklistLbl.snp_bottom).offset(3)
                    make.size.equalTo(CGSizeMake(51, 31))
                })
            blacklistBtn.on = user!.blacklisted
        }
        // 创建第二版面
        container2 = UIView()
        container.addSubview(container2)
        container2.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(container1)
        }
        container2.layer.opacity = 0
        container2.hidden = true
        //
        var headerView = sepLine
        var index = 0
        for title in kReportTitles {
            let btn = UIButton()
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            btn.tag = index
            btn.addTarget(self, action: #selector(ReportBlacklistViewController.reportItemPressed(_:)), forControlEvents: .TouchUpInside)
            container2.addSubview(btn)
            btn.snp_makeConstraints(closure: { (make) -> Void in
                make.centerX.equalTo(container2)
                make.top.equalTo(headerView.snp_bottom).offset(45)
                make.height.equalTo(24)
                make.width.equalTo(container2)
            })
            headerView = btn
            index += 1
        }
    }
    
    func reportBtnPressed() {
        self.container2.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.container1.layer.opacity = 0
            self.container2.layer.opacity = 1
            }) { (_) -> Void in
                self.container1.hidden = true
        }
    }
    
    func reportItemPressed(sender: UIButton) {
        // TODO: 将举报内容发送给服务器
        showToast(LS("举报内容发送成功"), onSelf: true)
        hideAnimated()
    }
    
    func blacklistPressed() {
        blacklist = blacklistBtn.on
        dirty = true
    }
    
    override func hideAnimated(completion: (() -> ())? = nil) {
        if dirty {
            // 提交拉黑请求
            let orignalState = user?.blacklisted
            user?.blacklisted = blacklist
            AccountRequester.sharedRequester.blacklistUser(user!, blacklist: blacklist, onSuccess: { (json) in
                if self.blacklist {
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserBlacklistedNotification, object: nil, userInfo: [kUserKey: self.user!])
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kUserUnBlacklistedNotification, object: nil, userInfo: [kUserKey: self.user!])
                }
                }, onError: { (code) in
                    AppManager.sharedAppManager.showToast(LS("操作失败，请检查您的网络设置"))
                    // reset it to the orignal state
                    self.user?.blacklisted = orignalState!
            })
        }
        super.hideAnimated()
    }
}
