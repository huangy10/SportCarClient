//
//  PresentTemplate.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  弹出式的选项菜单的模板，实现了弹出和隐藏的动画，具体的内容留给子类实现
//  在present本窗口时，animate选项要设置为false，有本类来实现动画细节

import UIKit


class PresentTemplateViewController: InputableViewController {
    
    weak var parentController: UIViewController?
    
    var bg: UIImageView!
    var bgImage: UIImage!
    var bgBlurred: UIImageView!
    var bgMask: UIView!
    
    var container: UIView!
    var cancelBtn: UIButton!
    var sepLine: UIView!
    
    init(parent: UIViewController) {
        parentController = parent
        super.init()
        
        self.bgImage = parent.getScreenShotBlurred(false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimated()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        //
        bg = UIImageView(image: bgImage)
        superview.addSubview(bg)
        bg.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        bgBlurred = UIImageView(image: self.blurImageUsingCoreImage(bgImage))
        superview.addSubview(bgBlurred)
        bgBlurred.layer.opacity = 0
        bgBlurred.snp.makeConstraints { (make) -> Void in
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
        cancelBtn = UIButton()
        cancelBtn.addTarget(self, action: #selector(PresentTemplateViewController.cancelBtnPressed), for: .touchUpInside)
        superview.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(80)
            make.size.equalTo(44)
        }
        cancelBtn.addSubview(UIImageView.self).config(UIImage(named: "news_comment_cancel_btn"))
            .layout { (make) in
                make.center.equalTo(cancelBtn)
                make.size.equalTo(21)
        }
        //
        sepLine = UIView()
        superview.addSubview(sepLine)
        sepLine.backgroundColor = UIColor.white
        sepLine.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(cancelBtn)
            make.top.equalTo(cancelBtn.snp.bottom).offset(30)
            make.width.equalTo(220)
            make.height.equalTo(0.5)
        }
        createContent()
    }
    
    /**
     创建分割线以下部分的内容，留给子类实现
     */
    func createContent() {
        assertionFailure("Not implemented")
    }
    
    func showAnimated() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.bg.layer.opacity = 0
            self.bgBlurred.layer.opacity = 1
            self.bgMask.layer.opacity = 1
            self.container.layer.opacity = 1
        }) 
    }
    
    func hideAnimated(_ completion: (()->())? = nil) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlurred.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            self.container.layer.opacity = 0
            }, completion: { (_) -> Void in
                self.presentingViewController?.dismiss(animated: false, completion: completion)
        }) 
    }
    
    func cancelBtnPressed() {
        hideAnimated()
    }
    
}
