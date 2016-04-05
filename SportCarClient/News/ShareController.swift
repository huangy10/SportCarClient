//
//  ShareController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring


protocol ShareControllorDelegate: class {
    func shareControllerFinished()
}

// TODO: 将这个类改成PresentTemplateViewController的子类

class ShareController: UIViewController {
    weak var delegate: ShareControllorDelegate?
    // 背景图
    var bgImg: UIImage!
    var bg: UIImageView!
    var bgBlured: UIImageView!
    var bgMask: UIView!
    // 
    var container: UIView!
    var shareSina: UIButton!
    var shareWechat: UIButton!
    var shareQQ: UIButton!
    var shareWechatFriend: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
//        showAnimated()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showAnimated()
    }
    
    func showAnimated() {

        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.bg.layer.opacity = 0
            self.bgBlured.layer.opacity = 1
            self.bgMask.layer.opacity = 1
            self.container.layer.opacity = 1
            }, completion: nil)
//        SpringAnimation.spring(0.3) { () -> Void in
//            
//        }
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.blackColor()
        //
        bg = UIImageView(image: bgImg)
        superview.addSubview(bg)
        bg.layer.opacity = 1
        bg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        bgBlured = UIImageView(image: self.blurImageUsingCoreImage(bgImg))
        superview.addSubview(bgBlured)
        bgBlured.layer.opacity = 0
        bgBlured.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(bg)
        }
        //
        bgMask = UIView()
        bgMask.backgroundColor = UIColor(white: 1, alpha: 0.7)
        superview.addSubview(bgMask)
        bgMask.layer.opacity = 0
        //
        container = UIView()
        container.backgroundColor = UIColor.clearColor()
        superview.addSubview(container)
        container.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        container.layer.opacity = 0
        //
        let cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "news_comment_cancel_btn"), forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(ShareController.cancelBtnPressed), forControlEvents: .TouchUpInside)
        container.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(90)
            make.size.equalTo(21)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.whiteColor()
        container.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(cancelBtn.snp_bottom).offset(50)
            make.width.equalTo(220)
            make.height.equalTo(0.5)
        }
        //
        let shareLbl = UILabel()
        shareLbl.text = LS("分享")
        shareLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        shareLbl.textColor = UIColor.whiteColor()
        container.addSubview(shareLbl)
        shareLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(50)
        }
        //
        shareSina = UIButton()
        shareSina.tag = 2
        shareSina.setImage(UIImage(named: "share_sinaweibo"), forState: .Normal)
        shareSina.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(shareSina)
        shareSina.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container.snp_centerX).offset(15)
            make.top.equalTo(shareLbl.snp_bottom).offset(40)
            make.size.equalTo(50)
        }
        //
        shareQQ = UIButton()
        shareQQ.tag = 3
        shareQQ.setImage(UIImage(named: "share_qq"), forState: .Normal)
        shareQQ.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(shareQQ)
        shareQQ.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(shareSina.snp_right).offset(30)
            make.top.equalTo(shareSina)
            make.size.equalTo(50)
        }
        //
        shareWechatFriend = UIButton()
        shareWechatFriend.tag = 1
        shareWechatFriend.setImage(UIImage(named: "share_wechat_friend"), forState: .Normal)
        shareWechatFriend.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(shareWechatFriend)
        shareWechatFriend.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container.snp_centerX).offset(-15)
            make.top.equalTo(shareSina)
            make.size.equalTo(50)
        }
        //
        shareWechat = UIButton()
        shareWechat.tag = 0
        shareWechat.setImage(UIImage(named: "share_wechat"), forState: .Normal)
        shareWechat.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), forControlEvents: .TouchUpInside)
        container.addSubview(shareWechat)
        shareWechat.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(shareWechatFriend.snp_left).offset(-30)
            make.size.equalTo(50)
            make.top.equalTo(shareSina)
        }
    }

    func cancelBtnPressed() {
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlured.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            self.container.layer.opacity = 0
            }, completion: { _ in
                self.delegate?.shareControllerFinished()
        })
    }
    
    func shareBtnPressed(sender: UIButton) {
        
    }
}
