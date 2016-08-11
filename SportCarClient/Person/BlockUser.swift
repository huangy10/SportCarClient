//
//  BlockUser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/7/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class BlockUserController: UIViewController {
    
    var user: User
    var dirty: Bool = false
    
    var container: UIView!
    var closeBtn: UIButton!
    var sepLine: UIView!
    var blockLbl: UILabel!
    var blockSwitch: UISwitch!
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        createSubviews()
        animateEntry()
    }
    
    private func createSubviews() {
        let superview = self.view
        
        container = superview.addSubview(UIView).config(UIColor.clearColor())
            .layout({ (make) in
                make.edges.equalTo(superview)
            })
        container.layer.opacity = 0
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurMask = UIVisualEffectView(effect: blurEffect)
//        blurMask.layer.opacity = 0.9
        container.addSubview(blurMask)
        blurMask.snp_makeConstraints { (make) in
            make.edges.equalTo(container)
        }
        
        container.addSubview(UIView).config(UIColor(white: 0, alpha: 0.7))
        
        closeBtn = container.addSubview(UIButton).config(self, selector: #selector(closeBtnPressed))
            .layout({ (make) in
                make.centerX.equalTo(container)
                make.top.equalTo(container).offset(80)
                make.size.equalTo(44)
            })
        closeBtn.addSubview(UIImageView).config(UIImage(named: "news_comment_cancel_btn"))
            .layout { (make) in
                make.center.equalTo(closeBtn)
                make.size.equalTo(21)
        }
        
        sepLine = container.addSubview(UIView).config(UIColor.whiteColor())
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.top.equalTo(closeBtn.snp_bottom).offset(30)
                make.height.equalTo(0.5)
                make.width.equalTo(220)
            })
        blockLbl = container.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightUltraLight, textColor: UIColor.whiteColor(), textAlignment: .Center, text: LS("屏蔽"))
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.top.equalTo(sepLine.snp_bottom).offset(30)
            })
        blockSwitch = container.addSubview(UISwitch).config(self, selector: #selector(switchPressed))
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.size.equalTo(CGSizeMake(51, 31))
                make.top.equalTo(blockLbl.snp_bottom).offset(10)
            })
        blockSwitch.on = user.blacklisted
    }
    
    func animateEntry() {
        UIView.animateWithDuration(0.5) { 
            self.container.layer.opacity = 1
        }
    }

    func closeBtnPressed() {
        dismissSelf()
    }
    
    func dismissSelf() {
        if dirty && blockSwitch.on != user.blacklisted {
            AccountRequester2.sharedInstance.block(user, flag: blockSwitch.on, onSuccess: { (json) in
                let blocked = json!.boolValue
                self.user.blacklisted = blocked
                let blockStatus = blocked ? kAccountBlackStatusBlocked : kAccountBlackStatusDefault
                NSNotificationCenter.defaultCenter().postNotificationName(kAccountBlacklistChange, object: nil, userInfo: [kUserKey: self.user, kAccountBlackStatusKey: blockStatus])
                }, onError: { (code) in
                    UIApplication.sharedApplication().keyWindow?.rootViewController?.showToast(LS("操作失败"))
            })
        }
        UIView.animateWithDuration(0.5, animations: { 
            self.container.layer.opacity = 0
            }) { (_) in
                self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }
    
    func presentFrom(viewController: UIViewController) {
        willMoveToParentViewController(viewController)
        viewController.view.addSubview(view)
        viewController.addChildViewController(self)
        didMoveToParentViewController(viewController)
    }
    
    func presentFromRootViewController() {
        let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        presentFrom(viewController)
    }
    
    func switchPressed() {
        dirty = true
    }
}
