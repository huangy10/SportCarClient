//
//  ResetPassword.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class ResetPasswordController: LoginRegisterController {
    
    override func createSubviews() {
        self.navigationItem.title = NSLocalizedString("找回密码", comment: "")
        self.navigationItem.leftBarButtonItem = self.leftBarBtn()
        //
        let superview = self.view!
        superview.backgroundColor = UIColor.blackColor()
        //
        bgImgView = UIImageView(image: UIImage(named: "account_bg_image"))
        bgImgView.layer.opacity = 0.5
        superview.addSubview(bgImgView)
        bgImgView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
//        titleLbl = UILabel()
//        titleLbl?.clipsToBounds = true
//        titleLbl?.text = "跑车范"
//        titleLbl?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightBold)
//        titleLbl?.textColor = UIColor.whiteColor()
//        titleLbl?.textAlignment = NSTextAlignment.Center
//        superview.addSubview(titleLbl!)
//        titleLbl!.snp_makeConstraints { (make) -> Void in
//            make.width.equalTo(superview)
//            make.height.equalTo(125)
//            make.centerX.equalTo(superview)
//            make.top.equalTo(superview)
//        }
        titleLogo = UIImageView(image: UIImage(named: "account_title_logo"))
        superview.addSubview(titleLogo)
        titleLogo.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(40)
            make.height.equalTo(23)
            make.width.equalTo(81)
        }

        // 复用了注册页面的结构
        let panel = self.registerView()
        superview.addSubview(panel)
        panel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLogo!.snp_bottom).offset(43)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
        }
    }
    
    override func registerView() -> UIView! {
        let container = UIView()
        //
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.whiteColor()
        inputContainer.layer.cornerRadius = 4
        container.addSubview(inputContainer)
        inputContainer.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(container)
            make.centerX.equalTo(container)
            make.height.equalTo(150)
            make.width.equalTo(container).multipliedBy(0.733)
        }
        //
        let seqLine1 = UIView()
        seqLine1.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine1)
        seqLine1.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp_top).offset(50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        let seqLine2 = UIView()
        seqLine2.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine2)
        seqLine2.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp_bottom).offset(-50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        //
        registerPhoneInput = TextFieldWithLeadingIconView()
        registerPhoneInput?.delegate = self
        registerPhoneInput?.placeholder = NSLocalizedString("请输入您的手机号", comment: "")
        registerPhoneInput?.font = UIFont.systemFontOfSize(12)
        registerPhoneInput?.leftViewMode = UITextFieldViewMode.Always
        let registerPhoneInputIcon = UIImageView(image: UIImage(named: "account_phone_input"))
        registerPhoneInput?.leftView = registerPhoneInputIcon
        inputContainer.addSubview(registerPhoneInput!)
        registerPhoneInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.3333)
            make.left.equalTo(inputContainer).offset(10)
            make.width.equalTo(inputContainer).multipliedBy(0.65)
            make.top.equalTo(inputContainer)
        })
        //
        let sendCodeBtn = AuthCodeBtnView()
        sendCodeBtn.setTitle(NSLocalizedString("获取验证码", comment: ""), forState: .Normal)
        sendCodeBtn.displayText = NSLocalizedString("获取验证码", comment: "")
        sendCodeBtn.setTitleColor(UIColor(red: 1, green: 0.2667, blue: 0.2745, alpha: 1), forState: .Normal)
        sendCodeBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        inputContainer.addSubview(sendCodeBtn)
        sendCodeBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!.snp_right)
            make.right.equalTo(inputContainer).offset(-13)
            make.centerY.equalTo(registerPhoneInput!)
        }
        sendCodeBtn.addTarget(self, action: #selector(sendAuthCodePressed), forControlEvents: .TouchUpInside)
        self.authCodeBtn = sendCodeBtn
        //
        registerAuthCode = TextFieldWithLeadingIconView()
        registerAuthCode?.delegate = self
        registerAuthCode?.placeholder = NSLocalizedString("请输入验证码", comment: "")
        registerAuthCode?.font = UIFont.systemFontOfSize(14)
        registerAuthCode?.leftViewMode = UITextFieldViewMode.Always
        let registerAuthCodeIcon = UIImageView(image: UIImage(named: "account_auth_code"))
        registerAuthCode?.leftView = registerAuthCodeIcon
        inputContainer.addSubview(registerAuthCode!)
        registerAuthCode!.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!)
            make.top.equalTo(registerPhoneInput!.snp_bottom)
            make.right.equalTo(sendCodeBtn)
        }
        //
        registerPasswordInput = TextFieldWithLeadingIconView()
        registerPasswordInput?.delegate = self
        registerPasswordInput?.placeholder = NSLocalizedString("请输入新密码", comment: "")
        registerPasswordInput?.secureTextEntry = true
        registerPasswordInput?.font = UIFont.systemFontOfSize(14)
        registerPasswordInput?.leftViewMode = UITextFieldViewMode.Always
        let registerPasswordInputIcon = UIImageView(image: UIImage(named: "account_password_input"))
        registerPasswordInput?.leftView = registerPasswordInputIcon
        inputContainer.addSubview(registerPasswordInput!)
        registerPasswordInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.width.equalTo(registerAuthCode!)
            make.top.equalTo(registerAuthCode!.snp_bottom)
            make.centerX.equalTo(registerAuthCode!)
        })
        
        let registerBtn = UIButton()
        registerBtn.setBackgroundImage(UIImage(named: "account_resetpwd_confirm_btn"), forState: .Normal)
        registerBtn.layer.shadowColor = UIColor(red: 0.95, green: 0.21, blue: 0.21, alpha: 1).CGColor
        registerBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerBtn.layer.shadowRadius = 7
        registerBtn.layer.shadowOpacity = 1
        container.addSubview(registerBtn)
        registerBtn.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(inputContainer.snp_bottom).offset(75)
            make.centerX.equalTo(container)
        }
        return container
    }
    
    // MARK: 重写按钮的功能
    override func backBtnPressed(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popViewControllerAnimated(true)
    }
    //
    override func registerPressed() {
        
    }
//    
    override func leftBarBtn() -> UIBarButtonItem! {
        let btn = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: #selector(LoginRegisterController.backBtnPressed(_:)))
        btn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        return btn
    }
}