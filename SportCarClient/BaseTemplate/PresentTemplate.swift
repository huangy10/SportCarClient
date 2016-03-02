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


class PresentTemplateViewController: UIViewController {
    
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
        super.init(nibName: nil, bundle: nil)
        
        self.bgImage = parent.getScreenShotBlurred(false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showAnimated()
    }
    
    func createSubviews() {
        let superview = self.view
        //
        bg = UIImageView(image: bgImage)
        superview.addSubview(bg)
        bg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        bgBlurred = UIImageView(image: self.blurImageUsingCoreImage(bgImage))
        superview.addSubview(bgBlurred)
        bgBlurred.layer.opacity = 0
        bgBlurred.snp_makeConstraints { (make) -> Void in
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
        cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "news_comment_cancel_btn"), forState: .Normal)
        cancelBtn.addTarget(self, action: "cancelBtnPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(90)
            make.size.equalTo(21)
        }
        //
        sepLine = UIView()
        superview.addSubview(sepLine)
        sepLine.backgroundColor = UIColor.whiteColor()
        sepLine.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(cancelBtn)
            make.top.equalTo(cancelBtn.snp_bottom).offset(50)
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
        UIView.animateWithDuration(0.5) { () -> Void in
            self.bg.layer.opacity = 0
            self.bgBlurred.layer.opacity = 1
            self.bgMask.layer.opacity = 1
            self.container.layer.opacity = 1
        }
    }
    
    func hideAnimated() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlurred.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            self.container.layer.opacity = 0
            }) { (_) -> Void in
                self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    func cancelBtnPressed() {
        hideAnimated()
    }
    
}
