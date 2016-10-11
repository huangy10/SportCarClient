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
    
    func titleForShare() -> String
    
    func descriptionForShare() -> String
    
    func thumbnailForShare() -> UIImage
    
    func linkForShare() -> String

}

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
    
    var _tencentOAuth = TencentOAuth.init(appId: "1105301166", andDelegate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
//        showAnimated()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimated()
    }
    
    func showAnimated() {

        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
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
        let superview = self.view!
        superview.backgroundColor = UIColor.black
        //
        bg = UIImageView(image: bgImg)
        superview.addSubview(bg)
        bg.layer.opacity = 1
        bg.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        bgBlured = UIImageView(image: self.blurImageUsingCoreImage(bgImg))
        superview.addSubview(bgBlured)
        bgBlured.layer.opacity = 0
        bgBlured.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(bg)
        }
        //
        bgMask = UIView()
        bgMask.backgroundColor = UIColor(white: 1, alpha: 0.7)
        superview.addSubview(bgMask)
        bgMask.layer.opacity = 0
        //
        container = UIView()
        container.backgroundColor = UIColor.clear
        superview.addSubview(container)
        container.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        container.layer.opacity = 0
        //
        let cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "news_comment_cancel_btn"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(ShareController.cancelBtnPressed), for: .touchUpInside)
        container.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(90)
            make.size.equalTo(21)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.white
        container.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(cancelBtn.snp.bottom).offset(50)
            make.width.equalTo(220)
            make.height.equalTo(0.5)
        }
        //
        let shareLbl = UILabel()
        shareLbl.text = LS("分享")
        shareLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        shareLbl.textColor = UIColor.white
        container.addSubview(shareLbl)
        shareLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(50)
        }
        //
        shareSina = UIButton()
        shareSina.tag = 2
        shareSina.setImage(UIImage(named: "share_sinaweibo"), for: .normal)
        shareSina.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(shareSina)
        shareSina.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container.snp.centerX).offset(15)
            make.top.equalTo(shareLbl.snp.bottom).offset(40)
            make.size.equalTo(50)
        }
        //
        shareQQ = UIButton()
        shareQQ.tag = 3
        shareQQ.setImage(UIImage(named: "share_qq"), for: .normal)
        shareQQ.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(shareQQ)
        shareQQ.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(shareSina.snp.right).offset(30)
            make.top.equalTo(shareSina)
            make.size.equalTo(50)
        }
        //
        shareWechatFriend = UIButton()
        shareWechatFriend.tag = 1
        shareWechatFriend.setImage(UIImage(named: "share_wechat_friend"), for: .normal)
        shareWechatFriend.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(shareWechatFriend)
        shareWechatFriend.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(container.snp.centerX).offset(-15)
            make.top.equalTo(shareSina)
            make.size.equalTo(50)
        }
        //
        shareWechat = UIButton()
        shareWechat.tag = 0
        shareWechat.setImage(UIImage(named: "share_wechat"), for: .normal)
        shareWechat.addTarget(self, action: #selector(ShareController.shareBtnPressed(_:)), for: .touchUpInside)
        container.addSubview(shareWechat)
        shareWechat.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(shareWechatFriend.snp.left).offset(-30)
            make.size.equalTo(50)
            make.top.equalTo(shareSina)
        }
    }

    func cancelBtnPressed() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlured.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            self.container.layer.opacity = 0
            }, completion: { _ in
                self.delegate?.shareControllerFinished()
        })
    }
    
    func shareBtnPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if !WXApi.isWXAppInstalled() {
                showToast(LS("请先安装微信客户端"), onSelf: true)
                return
            }
            if let delegate = delegate {
                let message = WXMediaMessage()
                message.title = delegate.titleForShare()
                message.description = delegate.descriptionForShare()
                message.setThumbImage(delegate.thumbnailForShare())
                let web = WXWebpageObject()
                web.webpageUrl = delegate.linkForShare()
                message.mediaObject = web
                let req = SendMessageToWXReq()
                req.bText = false
                req.scene = Int32(WXSceneSession.rawValue)
                req.message = message
                if !WXApi.send(req) {
                    showToast(LS("分享失败"), onSelf: true)
                }
            }
        case 1:
            if !WXApi.isWXAppInstalled() {
                showToast(LS("请先安装微信客户端"), onSelf: true)
                return
            }
            if let delegate = delegate {
                let message = WXMediaMessage()
                message.title = delegate.titleForShare()
                message.description = delegate.descriptionForShare()
                message.setThumbImage(delegate.thumbnailForShare())
                let web = WXWebpageObject()
                web.webpageUrl = delegate.linkForShare()
                message.mediaObject = web
                let req = SendMessageToWXReq()
                req.bText = false
                req.scene = Int32(WXSceneTimeline.rawValue)
                req.message = message
                if !WXApi.send(req) {
                    showToast(LS("分享失败"), onSelf: true)
                }
            }
        case 2:
            if !WeiboSDK.isWeiboAppInstalled() {
                showToast(LS("请先安装新浪微博客户端"), onSelf: true)
                return
            }
            if let delegate = delegate {
                let message = WBMessageObject()
                message.text = delegate.titleForShare()
                let ext = WBWebpageObject()
                ext.objectID = "sportcar_client"
                ext.webpageUrl = delegate.linkForShare()
                ext.title = delegate.titleForShare()
                ext.thumbnailData = UIImagePNGRepresentation(delegate.thumbnailForShare())
                ext.description = delegate.descriptionForShare()
                message.mediaObject = ext
                
                let req = WBSendMessageToWeiboRequest()
                req.message = message
                WeiboSDK.send(req)
            }
        case 3:
            if !QQApiInterface.isQQInstalled() {
                showToast(LS("请先安装QQ客户端"), onSelf: true)
                return
            }
            if let delegate = delegate {
                let message = QQApiNewsObject(url: URL(string: delegate.linkForShare()), title: delegate.titleForShare(), description: delegate.descriptionForShare(), previewImageData: UIImagePNGRepresentation(delegate.thumbnailForShare())!, targetContentType: QQApiURLTargetTypeNews)
                let req = SendMessageToQQReq(content: message)
                QQApiInterface.send(req)
            }
        default:
            assertionFailure()
        }

    }
}
