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
    
    fileprivate func createSubviews() {
        let superview = self.view!
        
        container = superview.addSubview(UIView.self).config(UIColor.clear)
            .layout({ (make) in
                make.edges.equalTo(superview)
            })
        container.layer.opacity = 0
        let blurEffect = UIBlurEffect(style: .dark)
        let blurMask = UIVisualEffectView(effect: blurEffect)
//        blurMask.layer.opacity = 0.9
        container.addSubview(blurMask)
        blurMask.snp.makeConstraints { (make) in
            make.edges.equalTo(container)
        }
        
        container.addSubview(UIView.self).config(UIColor(white: 0, alpha: 0.7))
        
        closeBtn = container.addSubview(UIButton.self).config(self, selector: #selector(closeBtnPressed))
            .layout({ (make) in
                make.centerX.equalTo(container)
                make.top.equalTo(container).offset(80)
                make.size.equalTo(44)
            })
        closeBtn.addSubview(UIImageView.self).config(UIImage(named: "news_comment_cancel_btn"))
            .layout { (make) in
                make.center.equalTo(closeBtn)
                make.size.equalTo(21)
        }
        
        sepLine = container.addSubview(UIView.self).config(UIColor.white)
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.top.equalTo(closeBtn.snp.bottom).offset(30)
                make.height.equalTo(0.5)
                make.width.equalTo(220)
            })
        blockLbl = container.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor.white, textAlignment: .center, text: LS("屏蔽"))
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.top.equalTo(sepLine.snp.bottom).offset(30)
            })
        blockSwitch = container.addSubview(UISwitch.self).config(self, selector: #selector(switchPressed))
            .layout({ (make) in
                make.centerX.equalTo(closeBtn)
                make.size.equalTo(CGSize(width: 51, height: 31))
                make.top.equalTo(blockLbl.snp.bottom).offset(10)
            })
        blockSwitch.isOn = user.blacklisted
    }
    
    func animateEntry() {
        UIView.animate(withDuration: 0.5, animations: { 
            self.container.layer.opacity = 1
        }) 
    }

    func closeBtnPressed() {
        dismissSelf()
    }
    
    func dismissSelf() {
        if dirty && blockSwitch.isOn != user.blacklisted {
            _ = AccountRequester2.sharedInstance.block(user, flag: blockSwitch.isOn, onSuccess: { (json) in
                let blocked = json!.boolValue
                self.user.blacklisted = blocked
                let blockStatus = blocked ? kAccountBlackStatusBlocked : kAccountBlackStatusDefault
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kAccountBlacklistChange), object: nil, userInfo: [kUserKey: self.user, kAccountBlackStatusKey: blockStatus])
                }, onError: { (code) in
                    UIApplication.shared.keyWindow?.rootViewController?.showToast(LS("操作失败"))
            })
        }
        UIView.animate(withDuration: 0.5, animations: { 
            self.container.layer.opacity = 0
            }, completion: { (_) in
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }) 
    }
    
    func presentFrom(_ viewController: UIViewController) {
        willMove(toParentViewController: viewController)
        viewController.view.addSubview(view)
        viewController.addChildViewController(self)
        didMove(toParentViewController: viewController)
    }
    
    func presentFromRootViewController() {
        let viewController = UIApplication.shared.keyWindow!.rootViewController!
        presentFrom(viewController)
    }
    
    func switchPressed() {
        dirty = true
    }
}
